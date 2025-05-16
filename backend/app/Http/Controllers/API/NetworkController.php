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
        $levels = min($request->query('levels', 5), 10); // Default to 5 levels, max 10
        $includeMore = $request->query('include_more', false); // Whether to include "more" indicator
        
        // Get current user's details for the root node
        $rootNode = [
            'id' => $user->id,
            'user_id' => $user->id,
            'full_name' => $user->full_name,
            'email' => $user->email,
            'affiliate_code' => $user->affiliate_code,
            'referral_id' => $user->referral_id,
            'created_at' => $user->created_at,
            'level' => 0, // User is always level 0 (top of their own network)
            'position' => 0, // Root position
            'isActive' => true,
            'status' => 'Active',
            'isCurrentUser' => true,
            'children' => [] // Will be populated
        ];
        
        // Get all downlines to the specified levels
        $rootNode['children'] = $this->getDownlineTree($user->id, $levels, 1, $includeMore);
        
        // Count total direct downlines
        $directDownlineCount = User::where('referral_id', $user->affiliate_code)->count();
        $rootNode['downlines'] = $directDownlineCount;
        
        // Calculate total members in network recursively
        $totalMembers = $this->calculateTotalNetworkMembers($rootNode);
        
        // Get upline if the user has one
        $upline = null;
        if ($user->referral_id) {
            $upline = $this->getUplineChain($user->referral_id);
        }
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'total_members' => $totalMembers,
                'direct_referrals' => $directDownlineCount,
                'user' => $rootNode, // Root node with all network data
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
        $levels = min($request->query('levels', 5), 10); // Default to 5 levels, max 10
        $page = $request->query('page', 1);
        $perPage = $request->query('per_page', 15);
        
        // Get direct downlines (level 1)
        $directDownlines = User::where('referral_id', $user->affiliate_code)
            ->select('id', 'full_name', 'email', 'phonenumber', 'affiliate_code', 'created_at', 'status')
            ->paginate($perPage);
        
        // Get total downlines count by level
        $downlineCounts = [];
        $totalDownlines = 0;
        
        for ($i = 1; $i <= $levels; $i++) {
            $levelCount = $this->getDownlineCountByLevel($user->affiliate_code, $i);
            $downlineCounts["level_{$i}"] = $levelCount;
            $totalDownlines += $levelCount;
        }
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'direct_downlines' => $directDownlines,
                'downline_counts' => $downlineCounts,
                'total_downlines' => $totalDownlines
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
            $count = $this->getDownlineCountByLevel($user->affiliate_code, $i);
            $downlineCounts["level_{$i}"] = $count;
            $totalDownlines += $count;
        }
        
        // Get recent downlines
        $recentDownlines = User::where('referral_id', $user->affiliate_code)
            ->select('id', 'full_name', 'email', 'created_at', 'status')
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
     * @param  bool $includeMore - Whether to include a "more" indicator for levels with more children
     * @return array
     */
    private function getDownlineTree($userId, $maxLevel, $currentLevel = 1, $includeMore = false)
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
            ->select('id', 'full_name', 'email', 'affiliate_code', 'referral_id', 'created_at', 'status')
            ->get();
        
        $result = [];
        $position = 0;
        
        foreach ($downlines as $downline) {
            $children = [];
            $hasMoreChildren = false;
            
            if ($currentLevel < $maxLevel) {
                // Get downline's children
                $children = $this->getDownlineTree($downline->id, $maxLevel, $currentLevel + 1, $includeMore);
            } else if ($includeMore && $currentLevel == $maxLevel) {
                // Check if there are more children beyond max level
                $moreChildrenCount = User::where('referral_id', $downline->affiliate_code)->count();
                $hasMoreChildren = $moreChildrenCount > 0;
            }
            
            // Format the downline data
            $downlineData = [
                'id' => $downline->affiliate_code, // Use affiliate_code as ID for frontend
                'user_id' => $downline->id,
                'full_name' => $downline->full_name,
                'name' => $downline->full_name, // For frontend consistency
                'email' => $downline->email,
                'affiliate_code' => $downline->affiliate_code,
                'referral_id' => $downline->referral_id,
                'created_at' => $downline->created_at,
                'joinDate' => $downline->created_at->format('M d, Y'),
                'level' => $currentLevel,
                'position' => $position++,
                'isActive' => $downline->status !== 'Inactive',
                'status' => $downline->status ?? 'Active',
                'children' => $children,
                'children_count' => count($children),
                'downlines' => count($children)
            ];
            
            // Add indicator if there are more children beyond max level
            if ($hasMoreChildren) {
                $downlineData['has_more_children'] = true;
                $downlineData['more_children_count'] = $moreChildrenCount;
            }
            
            $result[] = $downlineData;
        }
        
        return $result;
    }

    /**
     * Get downline count by level
     *
     * @param  string  $affiliateCode
     * @param  int  $level
     * @return int
     */
    private function getDownlineCountByLevel($affiliateCode, $level)
    {
        if ($level == 1) {
            return User::where('referral_id', $affiliateCode)->count();
        }
        
        $level1Referrals = User::where('referral_id', $affiliateCode)
                               ->pluck('affiliate_code')
                               ->toArray();
        
        if (empty($level1Referrals)) {
            return 0;
        }
        
        return $this->getDownlineCountForCodes($level1Referrals, $level - 1);
    }

    /**
     * Get downline count for multiple affiliate codes
     *
     * @param  array  $affiliateCodes
     * @param  int  $level
     * @return int
     */
    private function getDownlineCountForCodes($affiliateCodes, $level)
    {
        if ($level == 1) {
            return User::whereIn('referral_id', $affiliateCodes)->count();
        }
        
        $nextLevelCodes = User::whereIn('referral_id', $affiliateCodes)
                             ->pluck('affiliate_code')
                             ->toArray();
        
        if (empty($nextLevelCodes)) {
            return 0;
        }
        
        return $this->getDownlineCountForCodes($nextLevelCodes, $level - 1);
    }

    /**
     * Get upline chain
     *
     * @param  string  $referralId
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
            $upline = User::where('affiliate_code', $currentReferralId)
                ->select('id', 'full_name', 'email', 'affiliate_code', 'referral_id', 'created_at', 'status')
                ->first();
            
            if (!$upline) {
                break;
            }
            
            $result[] = [
                'user_id' => $upline->id,
                'id' => $upline->affiliate_code,
                'full_name' => $upline->full_name,
                'name' => $upline->full_name,
                'email' => $upline->email,
                'affiliate_code' => $upline->affiliate_code,
                'level' => -($level + 1), // Use negative levels for upline (-1, -2, etc.)
                'isActive' => $upline->status !== 'Inactive',
                'status' => $upline->status ?? 'Active',
                'joinDate' => $upline->created_at->format('M d, Y'),
            ];
            
            $currentReferralId = $upline->referral_id;
            $level++;
        }
        
        return $result;
    }
    
    /**
     * Get simplified network summary with accurate counts
     * Focused endpoint for UI that just needs the total members and direct referrals
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getNetworkSummary(Request $request)
    {
        $user = $request->user();
        
        // Get direct referrals count (level 1)
        $directReferrals = User::where('referral_id', $user->affiliate_code)->count();
        
        // Calculate total members across all levels
        $totalMembers = $this->calculateTotalNetworkSize($user->affiliate_code);
        
        // Optional: Calculate the maximum depth of the network
        $maxDepth = $this->calculateNetworkMaxDepth($user->affiliate_code);
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'direct_referrals' => $directReferrals,
                'total_members' => $totalMembers,
                'max_depth' => $maxDepth,
                'timestamp' => now()->toIso8601String()
            ]
        ]);
    }
    
    /**
     * Calculate the total number of members in a network
     * Uses efficient queries to count all levels at once
     *
     * @param  string  $rootAffiliateCode
     * @return int
     */
    private function calculateTotalNetworkSize($rootAffiliateCode)
    {
        // Start with level 1 (direct referrals)
        $totalMembers = User::where('referral_id', $rootAffiliateCode)->count();
        
        // If no direct referrals, return 0
        if ($totalMembers == 0) {
            return 0;
        }
        
        // Get all affiliate codes of direct referrals
        $level1Codes = User::where('referral_id', $rootAffiliateCode)
                          ->pluck('affiliate_code')
                          ->toArray();
        
        // Initialize for tracking each level
        $currentLevelCodes = $level1Codes;
        $maxLevels = 10; // Prevent infinite recursion
        
        // Process levels 2 through maxLevels
        for ($level = 2; $level <= $maxLevels; $level++) {
            if (empty($currentLevelCodes)) {
                break; // No more downlines at this level
            }
            
            // Get all referrals at this level
            $referrals = User::whereIn('referral_id', $currentLevelCodes)->get();
            $levelCount = $referrals->count();
            
            // If no referrals at this level, we're done
            if ($levelCount == 0) {
                break;
            }
            
            // Add this level's count to total
            $totalMembers += $levelCount;
            
            // Prepare for next level
            $currentLevelCodes = $referrals->pluck('affiliate_code')->toArray();
        }
        
        return $totalMembers;
    }
    
    /**
     * Calculate the maximum depth of a network
     *
     * @param  string  $rootAffiliateCode
     * @return int
     */
    private function calculateNetworkMaxDepth($rootAffiliateCode)
    {
        // If user has no direct referrals, depth is 0
        $hasDirectReferrals = User::where('referral_id', $rootAffiliateCode)->exists();
        if (!$hasDirectReferrals) {
            return 0;
        }
        
        // Start with level 1
        $depth = 1;
        $currentLevelCodes = [
            $rootAffiliateCode
        ];
        $maxLevels = 10; // Prevent infinite loops
        
        for ($level = 2; $level <= $maxLevels; $level++) {
            // Get referrals for current level
            $nextLevelCodes = User::whereIn('referral_id', $currentLevelCodes)
                                 ->pluck('affiliate_code')
                                 ->toArray();
            
            if (empty($nextLevelCodes)) {
                break; // No more levels
            }
            
            $depth = $level - 1; // Adjust depth (level 2 means depth 1, etc.)
            $currentLevelCodes = $nextLevelCodes;
        }
        
        return $depth;
    }
    
    /**
     * Calculate total members in network from a node structure (for getNetwork endpoint)
     *
     * @param  array  $node
     * @return int
     */
    private function calculateTotalNetworkMembers($node)
    {
        $total = 0;
        
        // Count direct children
        $children = $node['children'] ?? [];
        $total += count($children);
        
        // Recursively count all grandchildren
        foreach ($children as $child) {
            $childrenCount = $this->countAllChildren($child);
            $total += $childrenCount;
        }
        
        return $total;
    }
    
    /**
     * Count all children recursively for a node
     *
     * @param  array  $node
     * @return int
     */
    private function countAllChildren($node)
    {
        $total = 0;
        $children = $node['children'] ?? [];
        
        // Count direct children
        $total = count($children);
        
        // Recursively count all their children
        foreach ($children as $child) {
            $total += $this->countAllChildren($child);
        }
        
        return $total;
    }

    /**
     * Get a specific node's network with deeper levels
     * Used for "view more" functionality in the network visualization
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $affiliateCode
     * @return \Illuminate\Http\JsonResponse
     */
    public function getNetworkNode(Request $request, $affiliateCode)
    {
        // Validate if user has access to this node
        $user = $request->user();
        $levels = min($request->query('levels', 5), 10); // Default to 5 levels, max 10
        $includeMore = $request->query('include_more', true);
        
        // Find the node by affiliate code
        $node = User::where('affiliate_code', $affiliateCode)
            ->select('id', 'full_name', 'email', 'affiliate_code', 'referral_id', 'created_at', 'status')
            ->first();
            
        if (!$node) {
            return response()->json([
                'status' => 'error',
                'message' => 'Network node not found'
            ], 404);
        }
        
        // Format the node data
        $nodeData = [
            'id' => $node->affiliate_code,
            'user_id' => $node->id,
            'full_name' => $node->full_name,
            'name' => $node->full_name,
            'email' => $node->email,
            'affiliate_code' => $node->affiliate_code,
            'referral_id' => $node->referral_id,
            'created_at' => $node->created_at,
            'joinDate' => $node->created_at->format('M d, Y'),
            'level' => 0, // This is level 0 relative to itself
            'position' => 0,
            'isActive' => $node->status !== 'Inactive',
            'status' => $node->status ?? 'Active',
            'children' => [] // Will be populated below
        ];
        
        // Get the children for this node
        $nodeData['children'] = $this->getDownlineTree($node->id, $levels, 1, $includeMore);
        
        // Count direct downlines
        $directDownlineCount = User::where('referral_id', $node->affiliate_code)->count();
        $nodeData['downlines'] = $directDownlineCount;
        
        // Calculate total members in this node's network
        $totalMembers = $this->calculateTotalNetworkSize($node->affiliate_code);
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'node' => $nodeData,
                'total_members' => $totalMembers,
                'direct_referrals' => $directDownlineCount
            ]
        ]);
    }
}
