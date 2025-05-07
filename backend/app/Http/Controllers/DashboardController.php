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
}
