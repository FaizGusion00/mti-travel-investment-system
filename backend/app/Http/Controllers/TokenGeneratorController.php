<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TokenGeneratorController extends Controller
{
    /**
     * Show the token generator page.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        return view('token-generator');
    }

    /**
     * Generate a new token for the authenticated user.
     * This will invalidate all previous tokens.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function generateToken(Request $request)
    {
        // Get the authenticated user
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not authenticated'
            ], 401);
        }

        // Delete existing tokens for this user
        $user->tokens()->delete();

        // Generate a new token with 3 days expiry
        $token = $user->createToken('auth_token', ['*'], now()->addDays(3))->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'New token generated successfully',
            'token' => $token,
            'expires_at' => now()->addDays(3)->toDateTimeString()
        ]);
    }

    /**
     * Revoke all tokens for the authenticated user.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function revokeTokens(Request $request)
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not authenticated'
            ], 401);
        }

        // Delete all tokens for this user
        $user->tokens()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'All tokens revoked successfully'
        ]);
    }

    /**
     * Get current token information.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTokenInfo(Request $request)
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not authenticated'
            ], 401);
        }

        $currentToken = $request->user()->currentAccessToken();

        return response()->json([
            'status' => 'success',
            'token_info' => [
                'token_id' => $currentToken->id,
                'name' => $currentToken->name,
                'abilities' => $currentToken->abilities,
                'last_used_at' => $currentToken->last_used_at,
                'expires_at' => $currentToken->expires_at,
            ]
        ]);
    }
}
