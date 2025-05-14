<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLog;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class WalletController extends Controller
{
    /**
     * Get wallet balances for the authenticated user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getWalletBalances(Request $request)
    {
        $user = $request->user();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'cash_wallet' => $user->cash_wallet,
                'voucher_wallet' => $user->voucher_wallet,
                'travel_wallet' => $user->travel_wallet,
                'xlm_wallet' => $user->xlm_wallet,
                'is_trader' => $user->is_trader
            ]
        ]);
    }
    
    /**
     * Transfer funds from trader to another user
     * Only traders can perform this operation
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function transferFunds(Request $request)
    {
        $user = $request->user();
        
        // Check if user is a trader
        if (!$user->is_trader) {
            return response()->json([
                'status' => 'error',
                'message' => 'Only traders can transfer funds to other users'
            ], 403);
        }
        
        // Validate the request with support for multiple identifier types
        $validator = Validator::make($request->all(), [
            'recipient_email' => 'required_without_all:recipient_phone,recipient_id,recipient_affiliate_code|email|exists:users,email',
            'recipient_phone' => 'required_without_all:recipient_email,recipient_id,recipient_affiliate_code|string|exists:users,phonenumber',
            'recipient_id' => 'required_without_all:recipient_email,recipient_phone,recipient_affiliate_code|numeric|exists:users,id',
            'recipient_affiliate_code' => 'required_without_all:recipient_email,recipient_phone,recipient_id|string|exists:users,affiliate_code',
            'wallet_type' => 'required|in:cash_wallet',
            'amount' => 'required|numeric|min:0.01',
            'notes' => 'nullable|string|max:255'
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }
        
        // Find recipient based on the provided identifier
        $recipient = null;
        
        if ($request->has('recipient_email')) {
            $recipient = User::where('email', $request->recipient_email)->first();
        } elseif ($request->has('recipient_phone')) {
            $recipient = User::where('phonenumber', $request->recipient_phone)->first();
        } elseif ($request->has('recipient_id')) {
            $recipient = User::where('id', $request->recipient_id)->first();
        } elseif ($request->has('recipient_affiliate_code')) {
            $recipient = User::where('affiliate_code', $request->recipient_affiliate_code)->first();
        }
        
        // Double-check that we found a recipient
        if (!$recipient) {
            return response()->json([
                'status' => 'error',
                'message' => 'Recipient not found'
            ], 404);
        }
        
        $walletType = $request->wallet_type;
        $amount = (float) $request->amount;
        
        // Check if trader has sufficient funds
        if ($user->$walletType < $amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient funds in your wallet'
            ], 400);
        }
        
        // Perform the transfer
        $user->$walletType -= $amount;
        $recipient->$walletType += $amount;
        
        // Save changes
        $user->save();
        $recipient->save();
        
        // Log the transaction for the sender
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => $walletType,
            'old_value' => (string) ($user->$walletType + $amount),
            'new_value' => (string) $user->$walletType,
            'action' => 'transfer_out',
            'ip_address' => $request->ip(),
            'created_at' => now(),
            'notes' => $request->notes ?? 'Transfer to ' . $recipient->full_name,
        ]);
        
        // Log the transaction for the recipient
        UserLog::create([
            'user_id' => $recipient->id,
            'column_name' => $walletType,
            'old_value' => (string) ($recipient->$walletType - $amount),
            'new_value' => (string) $recipient->$walletType,
            'action' => 'transfer_in',
            'ip_address' => $request->ip(),
            'created_at' => now(),
            'notes' => $request->notes ?? 'Transfer from ' . $user->full_name,
        ]);
        
        // Record in the transactions table
        $transaction = Transaction::create([
            'wallet_type' => $walletType,
            'from_account' => $user->id,
            'to_account' => $recipient->id,
            'amount' => $amount,
            'status' => 'success',
            'created_at' => now(),
        ]);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Funds transferred successfully',
            'data' => [
                'new_balance' => $user->$walletType,
                'recipient' => [
                    'id' => $recipient->id,
                    'full_name' => $recipient->full_name,
                    'email' => $recipient->email,
                    'affiliate_code' => $recipient->affiliate_code
                ],
                'amount' => $amount,
                'wallet_type' => $walletType,
                'notes' => $request->notes ?? null
            ]
        ]);
    }
    
    /**
     * Get transaction history for the authenticated user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTransactionHistory(Request $request)
    {
        $user = $request->user();
        $walletType = $request->query('wallet_type', 'cash_wallet');
        $page = $request->query('page', 1);
        $perPage = $request->query('per_page', 15);
        
        // Get transactions from both the transactions table and UserLog
        // First, get transactions from the Transaction model
        $transactions = Transaction::where(function($query) use ($user) {
                $query->where('from_account', $user->id)
                      ->orWhere('to_account', $user->id);
            })
            ->where('wallet_type', $walletType)
            ->with(['sender:id,full_name,email', 'recipient:id,full_name,email'])
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
        
        // Transform the data to include transaction direction (in/out)
        $transactions->getCollection()->transform(function ($transaction) use ($user) {
            $transaction->direction = $transaction->from_account == $user->id ? 'out' : 'in';
            return $transaction;
        });
        
        return response()->json([
            'status' => 'success',
            'data' => $transactions
        ]);
    }
    
    /**
     * Find a user by their id, affiliate_code, email, phone number, or name
     * Used for finding recipients for transfers
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function findUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'query' => 'required|string|min:2'
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $query = $request->query('query');
        
        // Log the search query for debugging
        \Log::info('User search query: ' . $query);
        
        // Check if the query is numeric (could be ID or phone)
        $isNumeric = is_numeric($query);
        
        // Start building the query
        $userQuery = User::query();
        
        // If it looks like an email
        if (filter_var($query, FILTER_VALIDATE_EMAIL)) {
            $userQuery->where('email', $query);
        } 
        // If it's a numeric value, it could be an ID or phone number
        elseif ($isNumeric) {
            $userQuery->where(function($q) use ($query) {
                $q->where('id', $query)
                  ->orWhere('phonenumber', 'like', "%{$query}%");
            });
        } 
        // Otherwise search across multiple fields
        else {
            $userQuery->where(function($q) use ($query) {
                $q->where('affiliate_code', 'like', "%{$query}%")
                  ->orWhere('email', 'like', "%{$query}%")
                  ->orWhere('full_name', 'like', "%{$query}%")
                  ->orWhere('phonenumber', 'like', "%{$query}%");
            });
        }
        
        // Get the results
        $users = $userQuery->select('id', 'full_name', 'email', 'phonenumber', 'affiliate_code', 'profile_image')
            ->limit(10)
            ->get();
        
        // Log the number of results found
        \Log::info('Found ' . $users->count() . ' users for query: ' . $query);
        
        // Add avatar_url to each user
        foreach ($users as $user) {
            $user->avatar_url = $user->getProfileImageUrlAttribute();
        }
        
        return response()->json([
            'status' => 'success',
            'data' => $users
        ]);
    }
    
    /**
     * Transfer funds between user's own wallets (internal transfer)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function transferBetweenWallets(Request $request)
    {
        $user = $request->user();
        
        // Validate the request
        $validator = Validator::make($request->all(), [
            'source_wallet' => 'required|in:cash_wallet,travel_wallet,xlm_wallet',
            'destination_wallet' => 'required|in:cash_wallet,travel_wallet,xlm_wallet|different:source_wallet',
            'amount' => 'required|numeric|min:0.01',
            'notes' => 'nullable|string|max:255'
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $sourceWallet = $request->source_wallet;
        $destinationWallet = $request->destination_wallet;
        $amount = (float) $request->amount;
        
        // Check if user has sufficient funds in source wallet
        if ($user->$sourceWallet < $amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient funds in your ' . $this->getWalletName($sourceWallet)
            ], 400);
        }
        
        // Perform the transfer
        $user->$sourceWallet -= $amount;
        $user->$destinationWallet += $amount;
        
        // Save changes
        $user->save();
        
        // Log the transaction for the source wallet
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => $sourceWallet,
            'old_value' => (string) ($user->$sourceWallet + $amount),
            'new_value' => (string) $user->$sourceWallet,
            'action' => 'internal_transfer_out',
            'ip_address' => $request->ip(),
            'created_at' => now(),
            'notes' => $request->notes ?? 'Transfer to ' . $this->getWalletName($destinationWallet),
        ]);
        
        // Log the transaction for the destination wallet
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => $destinationWallet,
            'old_value' => (string) ($user->$destinationWallet - $amount),
            'new_value' => (string) $user->$destinationWallet,
            'action' => 'internal_transfer_in',
            'ip_address' => $request->ip(),
            'created_at' => now(),
            'notes' => $request->notes ?? 'Transfer from ' . $this->getWalletName($sourceWallet),
        ]);
        
        // Record in the transactions table
        $transaction = Transaction::create([
            'wallet_type' => $sourceWallet,
            'from_account' => $user->id,
            'to_account' => $user->id, // Same user for internal transfers
            'amount' => $amount,
            'status' => 'success',
            'created_at' => now(),
            'notes' => 'Internal transfer: ' . $this->getWalletName($sourceWallet) . ' to ' . $this->getWalletName($destinationWallet),
            'transaction_type' => 'internal_transfer',
        ]);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Funds transferred successfully between your wallets',
            'data' => [
                'source_wallet' => [
                    'type' => $sourceWallet,
                    'name' => $this->getWalletName($sourceWallet),
                    'new_balance' => $user->$sourceWallet
                ],
                'destination_wallet' => [
                    'type' => $destinationWallet,
                    'name' => $this->getWalletName($destinationWallet),
                    'new_balance' => $user->$destinationWallet
                ],
                'amount' => $amount,
                'transaction_id' => $transaction->id
            ]
        ]);
    }
    
    /**
     * Get the friendly name of a wallet type
     * 
     * @param string $walletType
     * @return string
     */
    private function getWalletName($walletType)
    {
        $walletNames = [
            'cash_wallet' => 'Cash Wallet',
            'travel_wallet' => 'Travel Wallet',
            'xlm_wallet' => 'XLM Wallet',
            'voucher_wallet' => 'Voucher Wallet',
        ];
        
        return $walletNames[$walletType] ?? $walletType;
    }
}
