<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NetworkController extends Controller
{
    /**
     * Get user's network
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getNetwork(Request $request)
    {
        $user = $request->user();
        $levels = $request->query('levels', 5); // Default to 5 levels
        
        // Get downlines up to specified levels
        $downlines = $this->getDownlineTree($user->id, $levels);
        
        // Get upline
        $upline = $this->getUplineChain($user->referral_id);
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $user,
                'downlines' => $downlines,
                'upline' => $upline
            ]
        ]);
    }

    /**
     * Get user's downline
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getDownline(Request $request)
    {
        $user = $request->user();
        $levels = $request->query('levels', 5); // Default to 5 levels
        $page = $request->query('page', 1);
        $perPage = $request->query('per_page', 15);
        
        // Get direct downlines (level 1)
        $directDownlines = User::where('referral_id', $user->id)
            ->select('id', 'full_name', 'email', 'phonenumber', 'affiliate_code', 'created_at')
            ->paginate($perPage);
        
        // Get total downlines count by level
        $downlineCounts = [];
        for ($i = 1; $i <= $levels; $i++) {
            $downlineCounts["level_{$i}"] = $this->getDownlineCountByLevel($user->id, $i);
        }
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'direct_downlines' => $directDownlines,
                'downline_counts' => $downlineCounts,
                'total_downlines' => array_sum($downlineCounts)
            ]
        ]);
    }

    /**
     * Get user's upline
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUpline(Request $request)
    {
        $user = $request->user();
        
        // Get upline chain
        $upline = $this->getUplineChain($user->referral_id);
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'upline' => $upline
            ]
        ]);
    }

    /**
     * Get network statistics
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getNetworkStats(Request $request)
    {
        $user = $request->user();
        $levels = 5; // Default to 5 levels
        
        // Get downline counts by level
        $downlineCounts = [];
        $totalDownlines = 0;
        
        for ($i = 1; $i <= $levels; $i++) {
            $count = $this->getDownlineCountByLevel($user->id, $i);
            $downlineCounts["level_{$i}"] = $count;
            $totalDownlines += $count;
        }
        
        // Get recent downlines
        $recentDownlines = User::where('referral_id', $user->id)
            ->select('id', 'full_name', 'email', 'created_at')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'total_downlines' => $totalDownlines,
                'downline_counts' => $downlineCounts,
                'recent_downlines' => $recentDownlines
            ]
        ]);
    }

    /**
     * Get commissions
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCommissions(Request $request)
    {
        // This is a placeholder for the commission system
        // In a real application, you would calculate commissions based on your MLM rules
        
        return response()->json([
            'status' => 'success',
            'message' => 'Commission system is under development',
            'data' => [
                'commissions' => []
            ]
        ]);
    }

    /**
     * Get downline tree recursively
     *
     * @param  int  $userId - User ID of the person whose downlines we're finding
     * @param  int  $maxLevel - Maximum depth of levels to retrieve
     * @param  int  $currentLevel - Current level being processed
     * @return array
     */
    private function getDownlineTree($userId, $maxLevel, $currentLevel = 1)
    {
        if ($currentLevel > $maxLevel) {
            return [];
        }
        
        // Get the user's affiliate code first
        $user = User::select('affiliate_code')->find($userId);
        
        if (!$user || empty($user->affiliate_code)) {
            return [];
        }
        
        // Find users whose referral_id matches this user's affiliate_code
        $downlines = User::where('referral_id', $user->affiliate_code)
            ->select('id', 'full_name', 'email', 'affiliate_code', 'referral_id', 'created_at')
            ->get();
        
        $result = [];
        
        foreach ($downlines as $downline) {
            $children = [];
            
            if ($currentLevel < $maxLevel) {
                $children = $this->getDownlineTree($downline->id, $maxLevel, $currentLevel + 1);
            }
            
            $result[] = [
                'user_id' => $downline->id,
                'full_name' => $downline->full_name,
                'email' => $downline->email,
                'affiliate_code' => $downline->affiliate_code,
                'referral_id' => $downline->referral_id, // Include referral_id to help troubleshoot
                'created_at' => $downline->created_at,
                'level' => $currentLevel,
                'children' => $children,
                'children_count' => count($children)
            ];
        }
        
        return $result;
    }

    /**
     * Get downline count by level
     *
     * @param  string  $refCode
     * @param  int  $level
     * @return int
     */
    private function getDownlineCountByLevel($userId, $level)
    {
        if ($level == 1) {
            return User::where('referral_id', $userId)->count();
        }
        
        $downlines = User::where('referral_id', $userId)->pluck('id')->toArray();
        
        if (empty($downlines)) {
            return 0;
        }
        
        return $this->getDownlineCountForIds($downlines, $level - 1);
    }

    /**
     * Get downline count for multiple ref codes
     *
     * @param  array  $refCodes
     * @param  int  $level
     * @return int
     */
    private function getDownlineCountForIds($userIds, $level)
    {
        if ($level == 1) {
            return User::whereIn('referral_id', $userIds)->count();
        }
        
        $downlines = User::whereIn('referral_id', $userIds)->pluck('id')->toArray();
        
        if (empty($downlines)) {
            return 0;
        }
        
        return $this->getDownlineCountForIds($downlines, $level - 1);
    }

    /**
     * Get upline chain
     *
     * @param  string  $referenceCode
     * @return array
     */
    private function getUplineChain($referralId)
    {
        $result = [];
        $currentReferralId = $referralId;
        
        // Prevent infinite loops
        $maxLevels = 10;
        $level = 0;
        
        while ($currentReferralId && $level < $maxLevels) {
            $upline = User::where('id', $currentReferralId)
                ->select('id', 'full_name', 'email', 'affiliate_code', 'referral_id', 'created_at')
                ->first();
            
            if (!$upline) {
                break;
            }
            
            $result[] = [
                'user_id' => $upline->id,
                'full_name' => $upline->full_name,
                'email' => $upline->email,
                'affiliate_code' => $upline->affiliate_code,
                'level' => $level + 1
            ];
            
            $currentReferralId = $upline->referral_id;
            $level++;
        }
        
        return $result;
    }
}
