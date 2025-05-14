<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

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
        $user = $request->user();

        // Calculate avatar URL from profile_image
        $avatarUrl = null;
        if ($user->profile_image) {
            $avatarUrl = url('storage/' . $user->profile_image);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $user,
                'avatar_url' => $avatarUrl
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
                'app_name' => 'MetaTravel.ai',
                'version' => '1.0.0',
                'company_name' => 'MetaTravel.ai',
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
        $sortBy = $request->query('sort_by', 'created_at');
        $sortOrder = $request->query('sort_order', 'desc');

        $query = User::query();

        // Apply search if provided
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phonenumber', 'like', "%{$search}%")
                  ->orWhere('affiliate_code', 'like', "%{$search}%");
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
        try {
            $user = User::findOrFail($id);

            $rules = [
                'full_name' => 'sometimes|string|max:255',
                'username' => 'sometimes|string|max:255',
                'email' => 'sometimes|string|email|max:255|unique:users,email,' . $id . ',id',
                'phonenumber' => 'sometimes|string|max:20|unique:users,phonenumber,' . $id . ',id',
                'date_of_birth' => 'sometimes|date',
                'reference_code' => 'sometimes|string|nullable',
                'address' => 'sometimes|nullable|string|max:500',
                'is_trader' => 'sometimes|boolean',
                'status' => 'sometimes|in:pending,approved',
                'affiliate_code' => 'sometimes|string|nullable|max:10',
                'referral_id' => 'sometimes|string|nullable|max:10',
                'profile_image' => 'sometimes|nullable|image|mimes:jpeg,png,jpg|max:2048',
                'usdt_address' => 'sometimes|nullable|string|max:255',
            ];

            $validator = Validator::make($request->all(), $rules);
            
            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }
            
            $validatedData = $validator->validated();

            // Handle profile image upload if present
            if ($request->hasFile('profile_image')) {
                $imageFile = $request->file('profile_image');
                $fileName = time() . '_' . uniqid() . '.' . $imageFile->getClientOriginalExtension();
                $stored = $imageFile->storeAs('avatars', $fileName, 'public');
                if (!$stored) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Failed to upload profile image.'
                    ], 500);
                }
                $validatedData['profile_image'] = 'avatars/' . $fileName;
            }

            // Log changes
            foreach ($validatedData as $key => $value) {
                if ($user->$key != $value) {
                    UserLog::create([
                        'user_id' => $user->id,
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
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('User update error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update user: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete user (admin only)
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteUser($id)
    {
        try {
            $user = User::findOrFail($id);
            
            // Prevent deleting self
            if (auth()->id() == $user->id) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'You cannot delete your own account.'
                ], 403);
            }
            
            // Prevent deleting super admin (assume id 1 is super admin, adjust as needed)
            if ($user->id == 1) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'You cannot delete the super admin account.'
                ], 403);
            }
            
            // Log the deletion
            UserLog::create([
                'user_id' => auth()->id(),
                'column_name' => 'delete_user',
                'old_value' => 'User ID: ' . $user->id,
                'new_value' => 'User deleted: ' . $user->full_name . ' (' . $user->email . ')'
            ]);
            
            $user->delete();
            
            return response()->json([
                'status' => 'success',
                'message' => 'User deleted successfully'
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('User delete error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to delete user: ' . $e->getMessage()
            ], 500);
        }
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
        $logs = $user->logs()->orderBy('created_at', 'desc')->paginate($perPage);

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
        $newUsersToday = User::whereDate('created_at', today())->count();
        $newUsersThisWeek = User::whereBetween('created_at', [now()->startOfWeek(), now()])->count();
        $newUsersThisMonth = User::whereMonth('created_at', now()->month)->count();

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

        $registrationStats = User::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
            ->where('created_at', '>=', now()->subDays($days))
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
            ->where('created_at', '>=', now()->subDays($days))
            ->groupBy('column_name')
            ->orderBy('count', 'desc')
            ->get();

        $activityByDate = UserLog::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
            ->where('created_at', '>=', now()->subDays($days))
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
