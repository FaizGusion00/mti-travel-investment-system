<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /**
     * Register a new user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phonenumber' => 'required|string|max:20|unique:users',
            'address' => 'nullable|string|max:500',
            'date_of_birth' => 'required|date|before:-18 years',
            'reference_code' => 'nullable|string|exists:users,affiliate_code', // For backward compatibility
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Support both field names
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Generate a unique 6-character referral code
        $refCode = $this->generateUniqueRefCode();

        // Find referrer's affiliate code if provided
        $referralId = null;
        if ($request->reference_code) {
            // Store the referrer's affiliate_code directly in referral_id
            // based on the actual database structure
            $referralId = $request->reference_code;
        }

        // Handle profile image upload
        $profileImage = 'avatars/default.png';
        $imageFile = $request->file('profile_image') ?: $request->file('avatar');

        if ($imageFile) {
            $fileName = time() . '_' . Str::random(10) . '.' . $imageFile->getClientOriginalExtension();
            $imageFile->storeAs('avatars', $fileName, 'public');
            $profileImage = 'avatars/' . $fileName;
        }

        // Create user
        $user = User::create([
            'full_name' => $request->full_name,
            'email' => $request->email,
            'phonenumber' => $request->phonenumber,
            'address' => $request->address,
            'date_of_birth' => $request->date_of_birth,
            'referral_id' => $referralId,
            'profile_image' => $profileImage,
            'usdt_address' => null, // Initialize as null
            'password' => Hash::make($request->password),
            'affiliate_code' => $refCode,
        ]);

        // Generate OTP for email verification
        $otp = mt_rand(100000, 999999);

        // Store OTP in session or database
        // In a real application, you would send this OTP via email
        // For now, we'll return it in the response for testing purposes

        // Log the registration
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => 'registration',
            'old_value' => null,
            'new_value' => 'User registered'
        ]);

        // Add avatar_url to response
        $user->avatar_url = url('storage/' . $profileImage);

        return response()->json([
            'status' => 'success',
            'message' => 'User registered successfully. Please verify your email with the OTP.',
            'data' => [
                'user' => $user,
                'otp' => $otp, // In production, don't send this in response
                'avatar_url' => url('storage/' . $profileImage),
            ]
        ], 201);
    }

    /**
     * Login user and create token
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check email
        $user = User::where('email', $request->email)->first();

        // Check password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'The provided credentials are incorrect.'
            ], 401);
        }

        // Create token
        $deviceName = $request->ip();
        $token = $user->createToken($deviceName)->plainTextToken;

        // Log the login
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => 'login',
            'old_value' => null,
            'new_value' => 'User logged in'
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Login successful',
            'data' => [
                'user' => $user,
                'token' => $token,
            ]
        ]);
    }

    /**
     * Verify OTP for email verification
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:users,email',
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // In a real application, you would verify the OTP against what's stored
        // For this example, we'll assume the OTP is valid

        $user = User::where('email', $request->email)->first();

        // Log the verification
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => 'email_verification',
            'old_value' => null,
            'new_value' => 'Email verified'
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'OTP verified successfully',
        ]);
    }

    /**
     * Resend OTP for email verification
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Generate new OTP
        $otp = mt_rand(100000, 999999);

        // In a real application, you would store this OTP and send it via email

        return response()->json([
            'status' => 'success',
            'message' => 'OTP resent successfully',
            'data' => [
                'otp' => $otp, // In production, don't send this in response
            ]
        ]);
    }

    /**
     * Forgot password
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Generate password reset token
        $token = Str::random(60);

        // In a real application, you would store this token and send it via email

        return response()->json([
            'status' => 'success',
            'message' => 'Password reset link sent to your email',
            'data' => [
                'token' => $token, // In production, don't send this in response
            ]
        ]);
    }

    /**
     * Reset password
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:users,email',
            'token' => 'required|string',
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // In a real application, you would verify the token
        // For this example, we'll assume the token is valid

        $user = User::where('email', $request->email)->first();
        $user->password = Hash::make($request->password);
        $user->save();

        // Log the password reset
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => 'password',
            'old_value' => 'Password reset',
            'new_value' => 'Password reset'
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Password reset successfully',
        ]);
    }

    /**
     * Logout user (revoke token)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        // Log the logout
        UserLog::create([
            'user_id' => $request->user()->id,
            'column_name' => 'logout',
            'old_value' => null,
            'new_value' => 'User logged out'
        ]);

        // Revoke the token
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Generate a unique referral code
     *
     * @return string
     */
    private function generateUniqueRefCode()
    {
        $characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
        $refCode = '';

        do {
            $refCode = '';
            for ($i = 0; $i < 6; $i++) {
                $refCode .= $characters[rand(0, strlen($characters) - 1)];
            }
        } while (User::where('affiliate_code', $refCode)->exists());

        return $refCode;
    }
}
