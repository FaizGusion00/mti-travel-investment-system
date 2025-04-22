<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class TestController extends Controller
{
    /**
     * Test endpoint to check if API is working
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function test()
    {
        return response()->json([
            'status' => 'success',
            'message' => 'API is working correctly',
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Generate a test user and return a token
     * This is for testing purposes only
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTestToken()
    {
        // Create or retrieve a test user
        $user = User::firstOrCreate(
            ['email' => 'test@example.com'],
            [
                'full_name' => 'Test User',
                'phonenumber' => '1234567890',
                'date_of_birth' => now()->subYears(20),
                'profile_image' => 'default.png',
                'password' => Hash::make('Password123!'),
                'ref_code' => 'TEST01',
            ]
        );

        // Generate a token
        $token = $user->createToken('API Tester')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Test token generated successfully',
            'data' => [
                'user' => $user,
                'token' => $token,
                'usage_example' => 'Bearer ' . $token
            ]
        ]);
    }
}
