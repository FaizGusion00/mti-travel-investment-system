<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

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
     * Generate a token and redirect back to the token generator page.
     *
     * @return \Illuminate\Http\RedirectResponse
     */
    public function generateToken()
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

        // Delete existing tokens for this user
        $user->tokens()->delete();

        // Generate a new token
        $token = $user->createToken('API Tester')->plainTextToken;

        // Redirect back with the token
        return redirect()->route('token.generator')->with('token', $token);
    }
}
