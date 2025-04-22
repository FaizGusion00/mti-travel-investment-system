<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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
        $newUsersToday = User::whereDate('created_date', today())->count();
        $newUsersThisWeek = User::whereBetween('created_date', [now()->startOfWeek(), now()])->count();
        $newUsersThisMonth = User::whereMonth('created_date', now()->month)->count();

        // Get user registration trend data for chart
        $userTrend = User::select(DB::raw('DATE(created_date) as date'), DB::raw('count(*) as count'))
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
        $users = User::orderBy('created_date', 'desc')->paginate(10);
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
            ->orderBy('created_date', 'desc')
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
            ->orderBy('created_date', 'desc')
            ->paginate(10);

        return view('admin.user-detail', compact('user', 'userLogs'));
    }
}
