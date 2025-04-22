<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    /**
     * Get the authenticated user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCurrentUser(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $request->user()
            ]
        ]);
    }

    /**
     * Get app information
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function appInfo()
    {
        return response()->json([
            'status' => 'success',
            'data' => [
                'app_name' => 'Meta Travel International',
                'version' => '1.0.0',
                'company_name' => 'Meta Travel International',
                'support_email' => 'support@mti.com',
                'website' => 'https://mti.com',
                'terms_url' => 'https://mti.com/terms',
                'privacy_url' => 'https://mti.com/privacy',
                'api_status' => 'online',
                'timestamp' => now()->toIso8601String(),
            ]
        ]);
    }

    /**
     * Get all users (admin only)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAllUsers(Request $request)
    {
        $perPage = $request->query('per_page', 15);
        $search = $request->query('search');
        $sortBy = $request->query('sort_by', 'created_date');
        $sortOrder = $request->query('sort_order', 'desc');
        
        $query = User::query();
        
        // Apply search if provided
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phonenumber', 'like', "%{$search}%")
                  ->orWhere('ref_code', 'like', "%{$search}%");
            });
        }
        
        // Apply sorting
        $query->orderBy($sortBy, $sortOrder);
        
        // Paginate results
        $users = $query->paginate($perPage);
        
        return response()->json([
            'status' => 'success',
            'data' => $users
        ]);
    }

    /**
     * Get user by ID (admin only)
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserById($id)
    {
        $user = User::findOrFail($id);
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $user
            ]
        ]);
    }

    /**
     * Update user (admin only)
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateUser(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        $validatedData = $request->validate([
            'full_name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $id . ',user_id',
            'phonenumber' => 'sometimes|string|max:20|unique:users,phonenumber,' . $id . ',user_id',
            'date_of_birth' => 'sometimes|date',
            'reference_code' => 'sometimes|string',
            'usdt_address' => 'sometimes|nullable|string|max:255',
        ]);
        
        // Log changes
        foreach ($validatedData as $key => $value) {
            if ($user->$key != $value) {
                UserLog::create([
                    'user_id' => $user->user_id,
                    'column_name' => $key,
                    'old_value' => $user->$key,
                    'new_value' => $value
                ]);
            }
        }
        
        $user->update($validatedData);
        
        return response()->json([
            'status' => 'success',
            'message' => 'User updated successfully',
            'data' => [
                'user' => $user
            ]
        ]);
    }

    /**
     * Delete user (admin only)
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteUser($id)
    {
        $user = User::findOrFail($id);
        $user->delete();
        
        return response()->json([
            'status' => 'success',
            'message' => 'User deleted successfully'
        ]);
    }

    /**
     * Get user logs (admin only)
     *
     * @param  int  $id
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserLogs($id, Request $request)
    {
        $perPage = $request->query('per_page', 15);
        
        $user = User::findOrFail($id);
        $logs = $user->logs()->orderBy('created_date', 'desc')->paginate($perPage);
        
        return response()->json([
            'status' => 'success',
            'data' => $logs
        ]);
    }

    /**
     * Get user statistics (admin only)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserStats()
    {
        $totalUsers = User::count();
        $newUsersToday = User::whereDate('created_date', today())->count();
        $newUsersThisWeek = User::whereBetween('created_date', [now()->startOfWeek(), now()])->count();
        $newUsersThisMonth = User::whereMonth('created_date', now()->month)->count();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'total_users' => $totalUsers,
                'new_users_today' => $newUsersToday,
                'new_users_this_week' => $newUsersThisWeek,
                'new_users_this_month' => $newUsersThisMonth
            ]
        ]);
    }

    /**
     * Get registration statistics (admin only)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getRegistrationStats(Request $request)
    {
        $days = $request->query('days', 30);
        
        $registrationStats = User::select(DB::raw('DATE(created_date) as date'), DB::raw('count(*) as count'))
            ->where('created_date', '>=', now()->subDays($days))
            ->groupBy('date')
            ->orderBy('date')
            ->get();
        
        return response()->json([
            'status' => 'success',
            'data' => $registrationStats
        ]);
    }

    /**
     * Get activity statistics (admin only)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getActivityStats(Request $request)
    {
        $days = $request->query('days', 30);
        
        $activityByType = UserLog::select('column_name', DB::raw('count(*) as count'))
            ->where('created_date', '>=', now()->subDays($days))
            ->groupBy('column_name')
            ->orderBy('count', 'desc')
            ->get();
        
        $activityByDate = UserLog::select(DB::raw('DATE(created_date) as date'), DB::raw('count(*) as count'))
            ->where('created_date', '>=', now()->subDays($days))
            ->groupBy('date')
            ->orderBy('date')
            ->get();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'activity_by_type' => $activityByType,
                'activity_by_date' => $activityByDate
            ]
        ]);
    }
}
