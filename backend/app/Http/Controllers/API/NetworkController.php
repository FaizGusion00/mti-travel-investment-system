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
        $downlines = $this->getDownlineTree($user->ref_code, $levels);
        
        // Get upline
        $upline = $this->getUplineChain($user->reference_code);
        
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
        $directDownlines = User::where('reference_code', $user->ref_code)
            ->select('user_id', 'full_name', 'email', 'phonenumber', 'ref_code', 'created_at')
            ->paginate($perPage);
        
        // Get total downlines count by level
        $downlineCounts = [];
        for ($i = 1; $i <= $levels; $i++) {
            $downlineCounts["level_{$i}"] = $this->getDownlineCountByLevel($user->ref_code, $i);
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
        $upline = $this->getUplineChain($user->reference_code);
        
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
            $count = $this->getDownlineCountByLevel($user->ref_code, $i);
            $downlineCounts["level_{$i}"] = $count;
            $totalDownlines += $count;
        }
        
        // Get recent downlines
        $recentDownlines = User::where('reference_code', $user->ref_code)
            ->select('user_id', 'full_name', 'email', 'created_at')
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
     * @param  string  $refCode
     * @param  int  $maxLevel
     * @param  int  $currentLevel
     * @return array
     */
    private function getDownlineTree($refCode, $maxLevel, $currentLevel = 1)
    {
        if ($currentLevel > $maxLevel) {
            return [];
        }
        
        $downlines = User::where('reference_code', $refCode)
            ->select('user_id', 'full_name', 'email', 'ref_code', 'created_at')
            ->get();
        
        $result = [];
        
        foreach ($downlines as $downline) {
            $children = [];
            
            if ($currentLevel < $maxLevel) {
                $children = $this->getDownlineTree($downline->ref_code, $maxLevel, $currentLevel + 1);
            }
            
            $result[] = [
                'user_id' => $downline->user_id,
                'full_name' => $downline->full_name,
                'email' => $downline->email,
                'ref_code' => $downline->ref_code,
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
    private function getDownlineCountByLevel($refCode, $level)
    {
        if ($level == 1) {
            return User::where('reference_code', $refCode)->count();
        }
        
        $downlines = User::where('reference_code', $refCode)->pluck('ref_code')->toArray();
        
        if (empty($downlines)) {
            return 0;
        }
        
        return $this->getDownlineCountForCodes($downlines, $level - 1);
    }

    /**
     * Get downline count for multiple ref codes
     *
     * @param  array  $refCodes
     * @param  int  $level
     * @return int
     */
    private function getDownlineCountForCodes($refCodes, $level)
    {
        if ($level == 1) {
            return User::whereIn('reference_code', $refCodes)->count();
        }
        
        $downlines = User::whereIn('reference_code', $refCodes)->pluck('ref_code')->toArray();
        
        if (empty($downlines)) {
            return 0;
        }
        
        return $this->getDownlineCountForCodes($downlines, $level - 1);
    }

    /**
     * Get upline chain
     *
     * @param  string  $referenceCode
     * @return array
     */
    private function getUplineChain($referenceCode)
    {
        $result = [];
        $currentReferenceCode = $referenceCode;
        
        // Prevent infinite loops
        $maxLevels = 10;
        $level = 0;
        
        while ($currentReferenceCode != 'COMPANY' && $level < $maxLevels) {
            $upline = User::where('ref_code', $currentReferenceCode)
                ->select('user_id', 'full_name', 'email', 'ref_code', 'reference_code', 'created_at')
                ->first();
            
            if (!$upline) {
                break;
            }
            
            $result[] = [
                'user_id' => $upline->user_id,
                'full_name' => $upline->full_name,
                'email' => $upline->email,
                'ref_code' => $upline->ref_code,
                'level' => $level + 1
            ];
            
            $currentReferenceCode = $upline->reference_code;
            $level++;
        }
        
        return $result;
    }
}
