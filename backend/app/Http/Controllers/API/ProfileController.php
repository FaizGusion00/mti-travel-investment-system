<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    /**
     * Get user profile
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getProfile(Request $request)
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
     * Update user profile
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'full_name' => 'sometimes|string|max:255',
            'username' => 'sometimes|string|max:255',
            'phonenumber' => 'sometimes|string|max:20|unique:users,phonenumber,' . $user->id,
            'address' => 'sometimes|string|max:500',
            'date_of_birth' => 'sometimes|date|before:-18 years',
            'usdt_address' => 'sometimes|string|max:255|nullable',
            'affiliate_code' => [
                'sometimes',
                'string',
                'size:6',
                'unique:users,affiliate_code,' . $user->id,
                'regex:/^[A-Z0-9]*$/',
                function ($attribute, $value, $fail) {
                    // Ensure at least 3 letters
                    if (strlen(preg_replace('/[^A-Z]/', '', $value)) < 3) {
                        $fail('The referral code must contain at least 3 letters.');
                    }
                },
            ],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Log changes
        foreach ($request->only(['full_name', 'phonenumber', 'address', 'date_of_birth', 'usdt_address', 'affiliate_code']) as $key => $value) {
            if ($user->$key != $value) {
                UserLog::create([
                    'user_id' => $user->id,
                    'column_name' => $key,
                    'old_value' => $user->$key,
                    'new_value' => $value
                ]);
            }
        }

        $user->update($request->only(['full_name', 'username', 'phonenumber', 'address', 'date_of_birth', 'usdt_address', 'affiliate_code']));

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => $user
            ]
        ]);
    }

    /**
     * Update user avatar
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Get the image file from either field
        $imageFile = $request->file('avatar') ?: $request->file('profile_image');

        if (!$imageFile) {
            return response()->json([
                'status' => 'error',
                'message' => 'No image file provided'
            ], 422);
        }

        // Delete old avatar if it's not the default and exists
        $oldImage = $user->profile_image;
        if ($oldImage && $oldImage != 'avatars/default.png' && Storage::disk('public')->exists($oldImage)) {
            Storage::disk('public')->delete($oldImage);
        }

        // Store new avatar
        $fileName = time() . '_' . Str::random(10) . '.' . $imageFile->getClientOriginalExtension();
        $path = $imageFile->storeAs('avatars', $fileName, 'public');
        $profileImage = 'avatars/' . $fileName;

        // Log change
        UserLog::create([
            'user_id' => $user->id,
            'column_name' => 'profile_image',
            'old_value' => $oldImage,
            'new_value' => $profileImage
        ]);

        // Update user
        $user->profile_image = $profileImage;
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Avatar updated successfully',
            'data' => [
                'user' => $user,
                'avatar_url' => url('storage/' . $profileImage)
            ]
        ]);
    }

    /**
     * Change user password
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check current password
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Current password is incorrect'
            ], 401);
        }

        // Log change
        UserLog::create([
            'user_id' => $user->user_id,
            'column_name' => 'password',
            'old_value' => 'Password changed',
            'new_value' => 'Password changed'
        ]);

        // Update password
        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Request email update
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|max:255|unique:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Generate OTP for email verification
        $otp = mt_rand(100000, 999999);

        // In a real application, you would store this OTP and send it to the new email
        // For this example, we'll return it in the response for testing purposes

        return response()->json([
            'status' => 'success',
            'message' => 'Verification code sent to your new email',
            'data' => [
                'otp' => $otp, // In production, don't send this in response
                'new_email' => $request->email
            ]
        ]);
    }

    /**
     * Verify email update with OTP
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyEmailUpdate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|max:255|unique:users,email',
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // In a real application, you would verify the OTP
        // For this example, we'll assume it's valid

        // Log change
        UserLog::create([
            'user_id' => $user->user_id,
            'column_name' => 'email',
            'old_value' => $user->email,
            'new_value' => $request->email
        ]);

        // Update email
        $user->email = $request->email;
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Email updated successfully',
            'data' => [
                'user' => $user
            ]
        ]);
    }

    /**
     * Update wallet address
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateWallet(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'usdt_address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Log change
        UserLog::create([
            'user_id' => $user->user_id,
            'column_name' => 'usdt_address',
            'old_value' => $user->usdt_address,
            'new_value' => $request->usdt_address
        ]);

        // Update wallet
        $user->usdt_address = $request->usdt_address;
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Wallet address updated successfully',
            'data' => [
                'user' => $user
            ]
        ]);
    }
}
