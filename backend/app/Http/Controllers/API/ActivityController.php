<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ActivityController extends Controller
{
    /**
     * Get network activity for the authenticated user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getNetworkActivity(Request $request)
    {
        $user = $request->user();
        $perPage = $request->query('per_page', 10);
        
        // Get all downline users
        $downlineUserIds = $this->getDownlineUserIds($user->affiliate_code);
        
        // Combine the user's ID with downline IDs
        $networkUserIds = array_merge([$user->id], $downlineUserIds);
        
        // Get activities where either the user or related user is in the network
        $activities = ActivityLog::whereIn('user_id', $networkUserIds)
            ->orWhereIn('related_user_id', $networkUserIds)
            ->with(['user:id,full_name,affiliate_code,profile_image', 'relatedUser:id,full_name,affiliate_code,profile_image'])
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
        
        return response()->json([
            'status' => 'success',
            'data' => $activities
        ]);
    }

    /**
     * Get team achievements for the authenticated user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTeamAchievements(Request $request)
    {
        $user = $request->user();
        
        // Get network size and level counts
        $directReferrals = User::where('referral_id', $user->affiliate_code)->count();
        $totalNetworkSize = $this->calculateTotalNetworkSize($user->affiliate_code);
        $activeUsers = $this->getActiveUsersInNetwork($user->affiliate_code);
        
        // Define achievement goals
        $achievements = [
            [
                'title' => 'Growth Milestone',
                'description' => '10+ Team Members',
                'current' => $totalNetworkSize,
                'target' => 10,
                'progress' => min(1, $totalNetworkSize / 10),
                'percentage' => min(100, floor($totalNetworkSize / 10 * 100)) . '%',
                'color' => '#2ECC71'
            ],
            [
                'title' => 'Referral Champion',
                'description' => 'Direct Referrals: ' . $directReferrals . '/5',
                'current' => $directReferrals,
                'target' => 5,
                'progress' => min(1, $directReferrals / 5),
                'percentage' => min(100, floor($directReferrals / 5 * 100)) . '%',
                'color' => '#3498DB'
            ],
            [
                'title' => 'Team Activity',
                'description' => 'Weekly Active Members: ' . $activeUsers . '/5',
                'current' => $activeUsers,
                'target' => 5,
                'progress' => min(1, $activeUsers / 5),
                'percentage' => min(100, floor($activeUsers / 5 * 100)) . '%',
                'color' => '#F39C12'
            ],
        ];
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'achievements' => $achievements
            ]
        ]);
    }

    /**
     * Log a new activity
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logActivity(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'activity_type' => 'required|string|max:50',
            'description' => 'required|string|max:255',
            'related_user_id' => 'nullable|exists:users,id',
            'metadata' => 'nullable|array',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = $request->user();
        
        $activity = ActivityLog::create([
            'user_id' => $user->id,
            'activity_type' => $request->activity_type,
            'description' => $request->description,
            'related_user_id' => $request->related_user_id,
            'metadata' => $request->metadata,
        ]);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Activity logged successfully',
            'data' => $activity
        ]);
    }

    /**
     * Get downline user IDs
     *
     * @param  string  $affiliateCode
     * @return array
     */
    private function getDownlineUserIds($affiliateCode)
    {
        $directDownlines = User::where('referral_id', $affiliateCode)
            ->pluck('id', 'affiliate_code')
            ->toArray();
        
        if (empty($directDownlines)) {
            return [];
        }
        
        $allDownlineIds = array_keys($directDownlines);
        
        // Process deeper levels
        $codesForNextLevel = array_values($directDownlines);
        
        while (!empty($codesForNextLevel)) {
            $nextLevelDownlines = User::whereIn('referral_id', $codesForNextLevel)
                ->pluck('id', 'affiliate_code')
                ->toArray();
            
            if (empty($nextLevelDownlines)) {
                break;
            }
            
            $allDownlineIds = array_merge($allDownlineIds, array_keys($nextLevelDownlines));
            $codesForNextLevel = array_values($nextLevelDownlines);
        }
        
        return $allDownlineIds;
    }

    /**
     * Calculate total network size
     *
     * @param  string  $affiliateCode
     * @return int
     */
    private function calculateTotalNetworkSize($affiliateCode)
    {
        $directCount = User::where('referral_id', $affiliateCode)->count();
        
        if ($directCount === 0) {
            return 0;
        }
        
        $directDownlines = User::where('referral_id', $affiliateCode)
            ->pluck('affiliate_code')
            ->toArray();
        
        $totalCount = $directCount;
        
        // Calculate counts for deeper levels
        $codesForNextLevel = $directDownlines;
        
        while (!empty($codesForNextLevel)) {
            $levelCount = User::whereIn('referral_id', $codesForNextLevel)->count();
            
            if ($levelCount === 0) {
                break;
            }
            
            $totalCount += $levelCount;
            
            $codesForNextLevel = User::whereIn('referral_id', $codesForNextLevel)
                ->pluck('affiliate_code')
                ->toArray();
        }
        
        return $totalCount;
    }

    /**
     * Get active users in network
     *
     * @param  string  $affiliateCode
     * @return int
     */
    private function getActiveUsersInNetwork($affiliateCode)
    {
        $oneWeekAgo = now()->subDays(7);
        
        // Get all downline user IDs
        $downlineUserIds = $this->getDownlineUserIds($affiliateCode);
        
        if (empty($downlineUserIds)) {
            return 0;
        }
        
        // Count users with recent activity
        $activeUsers = User::whereIn('id', $downlineUserIds)
            ->where('updated_at', '>=', $oneWeekAgo)
            ->count();
        
        return $activeUsers;
    }
} 