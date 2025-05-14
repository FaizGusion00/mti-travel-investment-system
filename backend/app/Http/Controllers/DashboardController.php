<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DashboardController extends Controller
{
    /**
     * Show the dashboard.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Get user statistics
        $totalUsers = User::count();
        $newUsersToday = User::whereDate('created_at', today())->count();
        $newUsersThisWeek = User::whereBetween('created_at', [now()->startOfWeek(), now()])->count();
        $newUsersThisMonth = User::whereMonth('created_at', now()->month)->count();

        // Get user registration trend data for chart
        $userTrend = User::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
            ->groupBy('date')
            ->orderBy('date')
            ->limit(30)
            ->get();

        // Format data for charts
        $dates = $userTrend->pluck('date')->toArray();
        $counts = $userTrend->pluck('count')->toArray();

        return view('admin.dashboard', compact(
            'totalUsers',
            'newUsersToday',
            'newUsersThisWeek',
            'newUsersThisMonth',
            'dates',
            'counts'
        ));
    }

    /**
     * Show the user management page.
     *
     * @return \Illuminate\View\View
     */
    public function users()
    {
        $users = User::orderBy('created_at', 'desc')->paginate(10);
        return view('admin.users', compact('users'));
    }

    /**
     * Show the activity logs page.
     *
     * @return \Illuminate\View\View
     */
    public function logs()
    {
        $logs = UserLog::with('user')
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        // Get activity by type for chart
        $activityByType = UserLog::select('column_name', DB::raw('count(*) as count'))
            ->groupBy('column_name')
            ->orderBy('count', 'desc')
            ->get();

        // Format data for charts
        $logTypes = $activityByType->pluck('column_name')->toArray();
        $logCounts = $activityByType->pluck('count')->toArray();

        return view('admin.logs', compact('logs', 'logTypes', 'logCounts'));
    }

    /**
     * Show details for a specific user.
     *
     * @param  int  $id
     * @return \Illuminate\View\View
     */
    public function userDetail($id)
    {
        $user = User::findOrFail($id);
        $userLogs = UserLog::where('user_id', $id)
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return view('admin.user-detail', compact('user', 'userLogs'));
    }
    
    /**
     * Show the trader management page.
     *
     * @return \Illuminate\View\View
     */
    public function traders()
    {
        $traders = User::where('is_trader', true)
            ->orderBy('created_at', 'desc')
            ->paginate(10);
            
        $users = User::where('is_trader', false)
            ->orderBy('created_at', 'desc')
            ->paginate(10);
            
        return view('admin.traders', compact('traders', 'users'));
    }
    
    /**
     * Toggle trader status for a user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function toggleTraderStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $user->is_trader = !$user->is_trader;
        $user->save();
        
        // Log the action
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => 'is_trader',
            'old_value' => !$user->is_trader ? 'true' : 'false',
            'new_value' => $user->is_trader ? 'true' : 'false',
            'action' => 'update',
            'ip_address' => $request->ip(),
            'created_at' => now(),
        ]);
        
        $status = $user->is_trader ? 'trader' : 'regular user';
        return redirect()->back()->with('success', "User {$user->full_name} is now a {$status}");
    }
    
    /**
     * Update user wallet balance.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateWallet(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        $request->validate([
            'wallet_type' => 'required|in:cash_wallet,voucher_wallet,travel_wallet,xlm_wallet',
            'amount' => 'required|numeric|min:0',
            'operation' => 'required|in:add,subtract,set'
        ]);
        
        $walletType = $request->wallet_type;
        $amount = (float) $request->amount;
        $operation = $request->operation;
        $oldValue = $user->$walletType;
        
        switch ($operation) {
            case 'add':
                $user->$walletType += $amount;
                break;
            case 'subtract':
                if ($user->$walletType < $amount) {
                    return redirect()->back()->with('error', 'Insufficient funds in wallet');
                }
                $user->$walletType -= $amount;
                break;
            case 'set':
                $user->$walletType = $amount;
                break;
        }
        
        $user->save();
        
        // Log the action
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => $walletType,
            'old_value' => (string) $oldValue,
            'new_value' => (string) $user->$walletType,
            'action' => 'update',
            'ip_address' => $request->ip(),
            'created_at' => now(),
        ]);
        
        $walletName = str_replace('_', ' ', $walletType);
        return redirect()->back()->with('success', "User {$user->full_name}'s {$walletName} has been updated successfully");
    }

    /**
     * Update user details.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateUser(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);
            
            // Debug log for username field
            Log::debug('Username update data:', [
                'username_input' => $request->input('username'),
                'username_type' => gettype($request->input('username')),
                'raw_request' => $request->all()
            ]);
            
            // Clean up username field - if empty, set to null
            if ($request->has('username') && empty($request->input('username'))) {
                $request->merge(['username' => null]);
            }
            
            $validated = $request->validate([
                'full_name' => 'sometimes|string|max:255',
                'username' => 'sometimes|nullable|string|max:255',
                'email' => 'sometimes|string|email|max:255|unique:users,email,' . $id . ',id',
                'phonenumber' => 'sometimes|string|max:20|unique:users,phonenumber,' . $id . ',id',
                'date_of_birth' => 'sometimes|date',
                'address' => 'sometimes|nullable|string|max:500',
                'is_trader' => 'sometimes|boolean',
                'status' => 'sometimes|in:pending,approved',
                'affiliate_code' => 'sometimes|string|nullable|max:10',
                'referral_id' => 'sometimes|string|nullable|max:10',
                'usdt_address' => 'sometimes|nullable|string|max:255',
            ]);
            
            // Handle profile image upload if present
            if ($request->hasFile('profile_image')) {
                $imageFile = $request->file('profile_image');
                if ($imageFile->isValid()) {
                    // Delete old image if it exists and is not the default
                    if ($user->profile_image && $user->profile_image !== 'avatars/default.png') {
                        $oldImagePath = 'public/' . $user->profile_image;
                        if (\Storage::exists($oldImagePath)) {
                            \Storage::delete($oldImagePath);
                        }
                    }
                    
                    // Store new image
                    $fileName = time() . '_' . uniqid() . '.' . $imageFile->getClientOriginalExtension();
                    $stored = $imageFile->storeAs('avatars', $fileName, 'public');
                    if (!$stored) {
                        throw new \Exception('Failed to upload profile image.');
                    }
                    $validated['profile_image'] = 'avatars/' . $fileName;
                    
                    // Log the profile image change
                    Log::info('Profile image updated for user ID: ' . $user->id . ', New path: ' . $validated['profile_image']);
                } else {
                    throw new \Exception('Invalid profile image file.');
                }
            }
            
            // Log changes
            foreach ($validated as $key => $value) {
                if ($user->$key != $value) {
                    UserLog::create([
                        'user_id' => $user->id,
                        'column_name' => $key,
                        'old_value' => $user->$key,
                        'new_value' => $value,
                        'action' => 'update',
                        'ip_address' => $request->ip(),
                    ]);
                }
            }
            
            $user->update($validated);
            
            if ($request->ajax()) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'User updated successfully',
                    'user' => $user
                ]);
            }
            
            return redirect()->back()->with('success', 'User updated successfully');
        } catch (\Exception $e) {
            Log::error('User update error: ' . $e->getMessage());
            
            if ($request->ajax()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Failed to update user: ' . $e->getMessage()
                ], 500);
            }
            
            return redirect()->back()->with('error', 'Failed to update user: ' . $e->getMessage());
        }
    }
    
    /**
     * Delete a user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function deleteUser(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);
            
            // Prevent deleting self
            if (auth()->id() == $user->id) {
                if ($request->ajax()) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'You cannot delete your own account.'
                    ], 403);
                }
                
                return redirect()->back()->with('error', 'You cannot delete your own account.');
            }
            
            // Prevent deleting super admin (assume ID 1 is super admin)
            if ($user->id == 1) {
                if ($request->ajax()) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'You cannot delete the super admin account.'
                    ], 403);
                }
                
                return redirect()->back()->with('error', 'You cannot delete the super admin account.');
            }
            
            // Create a log before deleting
            UserLog::create([
                'user_id' => auth()->id(), // Log who performed the deletion
                'column_name' => 'user_deleted',
                'old_value' => 'User ID: ' . $user->id,
                'new_value' => 'User deleted: ' . $user->full_name . ' (' . $user->email . ')',
                'action' => 'delete',
                'ip_address' => $request->ip(),
            ]);
            
            $user->delete();
            
            if ($request->ajax()) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'User deleted successfully'
                ]);
            }
            
            return redirect()->route('admin.users')->with('success', 'User deleted successfully');
        } catch (\Exception $e) {
            Log::error('User delete error: ' . $e->getMessage());
            
            if ($request->ajax()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Failed to delete user: ' . $e->getMessage()
                ], 500);
            }
            
            return redirect()->back()->with('error', 'Failed to delete user: ' . $e->getMessage());
        }
    }

    /**
     * Get user data as JSON for the edit form.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserJson($id)
    {
        try {
            $user = User::findOrFail($id);
            
            // Return only the fields needed for editing
            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $user->id,
                    'full_name' => $user->full_name,
                    'username' => $user->username,
                    'email' => $user->email,
                    'phonenumber' => $user->phonenumber,
                    'date_of_birth' => $user->date_of_birth,
                    'address' => $user->address,
                    'is_trader' => $user->is_trader,
                    'status' => $user->status,
                    'affiliate_code' => $user->affiliate_code,
                    'referral_id' => $user->referral_id,
                    'usdt_address' => $user->usdt_address,
                    'profile_image' => $user->profile_image ? asset('storage/' . $user->profile_image) : null
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch user: ' . $e->getMessage()
            ], 500);
        }
    }
}
