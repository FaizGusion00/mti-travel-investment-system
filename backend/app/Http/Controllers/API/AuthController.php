<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLog;
use App\Models\Otp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

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
        // Hide long debug output in production
        if (!app()->environment('local')) {
            app()->configure('app');
            config(['app.debug' => false]);
        }
        
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

        // Clean up expired OTPs
        \App\Models\Otp::where('expires_at', '<', now())->delete();
        // Remove any existing OTP for this email
        \App\Models\Otp::where('email', $request->email)->delete();
        // Store registration data and OTP in otps table (JSON encode all registration fields needed)
        $otp = str_pad((string)mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $otpRecord = \App\Models\Otp::create([
            'email' => $request->email,
            'otp' => $otp,
            'type' => 'email_verification',
            'used' => false,
            'expires_at' => now()->addMinutes(15),
            'data' => json_encode([
                'full_name' => $request->full_name,
                'username' => $request->username,
                'phonenumber' => $request->phonenumber,
                'address' => $request->address,
                'date_of_birth' => $request->date_of_birth,
                'referral_id' => $referralId,
                'profile_image' => $profileImage,
                'password' => \Illuminate\Support\Facades\Hash::make($request->password),
                'affiliate_code' => $refCode
            ])
        ]);
        // Send OTP email
        $this->generateOTP($request->email, $request->full_name, $otp);
        return response()->json([
            'status' => 'success',
            'message' => 'Registration started. Please verify your email with the OTP.',
            'data' => [
                'otp' => app()->environment('local') ? $otp : null
            ]
        ], 201, ['Content-Type' => 'application/json'], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }

    /**
     * Login user and create token
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        // Hide long debug output in production
        if (!app()->environment('local')) {
            config(['app.debug' => false]);
        }
        
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
     * Resend OTP for email verification
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resendOtp(Request $request)
    {
        // Hide long debug output in production
        if (!app()->environment('local')) {
            config(['app.debug' => false]);
        }

        Log::info("OTP resend attempt for: {$request->email}");
        
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
        ]);

        if ($validator->fails()) {
            Log::error("OTP resend validation failed:", $validator->errors()->toArray());
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $email = $request->email;
        
        // First check: is there a user with this email?
        $user = User::where('email', $email)->first();
        
        // If user exists, check if already verified
        if ($user) {
            Log::info("Resend OTP - User exists: {$email}");
            if ($user->email_verified_at) {
                Log::info("User already verified: {$email}");
                return response()->json([
                    'status' => 'error',
                    'message' => 'Email is already verified'
                ], 400);
            }
            // User exists but is not verified - generate new OTP for verification
            // (This case is unusual - would mean user was created but not verified)
            $otp = $this->generateOTP($email, $user->full_name);
            
            return response()->json([
                'status' => 'success',
                'message' => 'New verification code sent',
                'data' => [
                    'otp' => app()->environment('local') ? $otp : null
                ]
            ]);
        }
        
        // Second check: If no user, find pending registration in OTP records
        $latestOtpRecord = \App\Models\Otp::where('email', $email)
            ->where('type', 'email_verification')
            ->latest()
            ->first();
            
        if (!$latestOtpRecord) {
            Log::error("No OTP record found for email: {$email}");
            return response()->json([
                'status' => 'error',
                'message' => 'No registration found for this email. Please start registration first.'
            ], 404);
        }
        
        Log::info("Found OTP record for email: {$email}");
        
        // Get registration data before invalidating
        $registrationData = null;
        if ($latestOtpRecord->data) {
            $registrationData = $latestOtpRecord->data;
        }
        
        // Invalidate all existing OTPs for this email
        \App\Models\Otp::where('email', $email)
            ->where('type', 'email_verification')
            ->update(['used' => true]);
            
        // Generate new OTP
        $otp = str_pad((string)mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);
        
        // Create new OTP record with previous registration data if available
        $newOtpRecord = \App\Models\Otp::create([
            'email' => $email,
            'otp' => $otp,
            'type' => 'email_verification',
            'used' => false,
            'expires_at' => now()->addMinutes(15),
            'data' => $registrationData
        ]);
        
        // Extract name from registration data for email
        $name = 'User';
        if ($registrationData) {
            try {
                $decodedData = json_decode($registrationData, true);
                if (isset($decodedData['full_name'])) {
                    $name = $decodedData['full_name'];
                }
            } catch (\Exception $e) {
                Log::error("Failed to decode registration data: " . $e->getMessage());
            }
        }
        
        // Send email with OTP
        $this->generateOTP($email, $name, $otp);
        
        return response()->json([
            'status' => 'success',
            'message' => 'New verification code sent',
            'data' => [
                'otp' => app()->environment('local') ? $otp : null
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
     * Generate a unique 6-character referral code
     *
     * @return string
     */
    private function generateUniqueRefCode()
    {
        $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        $refCode = '';

        do {
            // Generate a 6-character code
            for ($i = 0; $i < 6; $i++) {
                $refCode .= $characters[rand(0, strlen($characters) - 1)];
            }
        } while (User::where('affiliate_code', $refCode)->exists());

        return $refCode;
    }
    
    /**
     * Generate a 6-digit OTP for the given email and send it via email
     *
     * @param string $email
     * @param string $name
     * @param string|null $customOtp Optional custom OTP to use instead of generating a new one
     * @return string
     */
    private function generateOTP(string $email, string $name, string $customOtp = null): string
    {
        // Use provided OTP or generate a random 6-digit OTP
        $otp = $customOtp ?? str_pad((string)mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);
        
        Log::info("Generating OTP for {$email}: {$otp}");
        
        // Invalidate any existing OTPs for this email
        Otp::where('email', $email)
            ->where('type', 'email_verification')
            ->update(['used' => true]);
        
        // Create a new OTP record if one wasn't already created
        if (!$customOtp) {
            $otpRecord = Otp::create([
                'email' => $email,
                'otp' => $otp,
                'type' => 'email_verification',
                'expires_at' => Carbon::now()->addMinutes(15), // OTP valid for 15 minutes
                'used' => false
            ]);
            
            Log::info("Created new OTP record ID: {$otpRecord->id} for {$email}");
        } else {
            Log::info("Using existing OTP record for {$email}");
        }
        
        // Send OTP via email
        try {
            // Force queue to sync for immediate sending
            config(['queue.default' => 'sync']);
            
            Log::info("Attempting to send OTP email to {$email}");
            
            // Make sure mail settings are loaded
            config([
                'mail.mailer' => 'smtp',
                'mail.host' => 'email-smtp.us-east-1.amazonaws.com',
                'mail.port' => 587,
                'mail.username' => 'AKIAV2TTTIWH3SCHUE42',
                'mail.password' => 'BE50nk0RrCGTrlzN6EThDXdE6Rdm8+n6R+rj6E1D14LV',
                'mail.encryption' => 'tls',
                'mail.from.address' => 'verify@metatravel.ai',
                'mail.from.name' => 'Meta Travel International'
            ]);
            
            // Send email with high priority
            Mail::to($email)->send(new \App\Mail\OtpMail($otp, $name));
            
            // Always log the OTP for testing purposes
            Log::info("OTP for {$email}: {$otp}");
            Log::info("Email sent to {$email} from verify@metatravel.ai");
            
            // In development mode, also store OTP in cache for backup
            if (app()->environment('local') || app()->environment('development')) {
                try {
                    \Illuminate\Support\Facades\Cache::store('fallback')->put("otp:{$email}", $otp, 900); // 15 minutes
                    Log::info("OTP also stored in cache for {$email}");
                } catch (\Exception $cacheError) {
                    Log::warning("Failed to store OTP in cache: " . $cacheError->getMessage());
                }
            }
        } catch (\Exception $e) {
            // Log the detailed error for debugging
            Log::error("Failed to send OTP email to {$email}: {$e->getMessage()}");
            Log::error("Error trace: {$e->getTraceAsString()}");
            
            // Always log the OTP in case of email failure, so we can still test
            Log::info("OTP for {$email}: {$otp} (Email failed but OTP logged for testing)");
            
            // Store in cache as backup in case email fails
            try {
                \Illuminate\Support\Facades\Cache::store('fallback')->put("otp:{$email}", $otp, 900); // 15 minutes
                Log::info("OTP stored in cache after email failure for {$email}");
            } catch (\Exception $cacheError) {
                Log::warning("Failed to store OTP in cache after email failure: " . $cacheError->getMessage());
            }
        }
        
        return $otp;
    }
    
    /**
     * Verify OTP for email verification
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyOtp(Request $request)
    {
        // Clean up expired OTPs
        \App\Models\Otp::where('expires_at', '<', now())->delete();
        
        // Add debugging for this request
        Log::info("OTP verification attempt:", [
            'email' => $request->email,
            'otp' => $request->otp,
            'time' => now()->toDateTimeString()
        ]);
        
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'otp' => 'required|string|size:6',
        ]);
        
        if ($validator->fails()) {
            Log::error("OTP validation failed:", $validator->errors()->toArray());
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $email = $request->email;
        $otp = $request->otp;
        
        // Log current OTP records for this email (for debugging)
        $allOtpRecords = \App\Models\Otp::where('email', $email)
            ->where('type', 'email_verification')
            ->orderBy('created_at', 'desc')
            ->get();
            
        Log::info("All OTP records for {$email}:", $allOtpRecords->toArray());
        
        // Find the latest valid OTP for this email
        $otpRecord = \App\Models\Otp::where('email', $email)
            ->where('otp', $otp)
            ->where('type', 'email_verification')
            ->where('used', false)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();
            
        if (!$otpRecord) {
            Log::error("No valid OTP record found for {$email} with code {$otp}");
            
            // Check cache as a backup in case DB failed
            $cachedOtp = null;
            try {
                $cachedOtp = \Illuminate\Support\Facades\Cache::store('fallback')->get("otp:{$email}");
                Log::info("Checking cache for OTP. Cache has: " . ($cachedOtp ?? 'null'));
            } catch (\Exception $cacheError) {
                Log::warning("Failed to retrieve OTP from cache: " . $cacheError->getMessage());
            }
            
            if ($cachedOtp && $cachedOtp === $otp) {
                Log::info("OTP verified from cache for {$email}");
                
                // Check if user already exists
                $existingUser = \App\Models\User::where('email', $email)->first();
                if ($existingUser) {
                    $existingUser->update(['email_verified_at' => now()]);
                    Log::info("User verified from cache: {$email}");
                    return response()->json([
                        'status' => 'success',
                        'message' => 'Email verified successfully via cache.',
                        'user_existed' => true
                    ]);
                }
                
                // No existing user, but we have a valid OTP in cache - check for pending registration data
                $pendingOtpRecord = \App\Models\Otp::where('email', $email)
                    ->where('type', 'email_verification')
                    ->latest()
                    ->first();
                    
                if ($pendingOtpRecord && $pendingOtpRecord->data) {
                    // Use this record's data but mark it as used
                    Log::info("Using registration data from previous OTP record for {$email}");
                    $otpRecord = $pendingOtpRecord;
                    $otpRecord->update(['used' => true]);
                    
                    // Remove the cache entry
                    try {
                        \Illuminate\Support\Facades\Cache::store('fallback')->forget("otp:{$email}");
                        Log::info("Removed OTP from cache for {$email}");
                    } catch (\Exception $cacheError) {
                        Log::warning("Failed to remove OTP from cache: " . $cacheError->getMessage());
                    }
                } else {
                    // No registration data available - tell frontend to send backup data
                    Log::error("No registration data found for cached OTP verification: {$email}");
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Your verification code is valid, but we could not find your registration data. Please restart registration.',
                        'error' => 'Missing registration data',
                        'needs_backup_data' => true
                    ], 400);
                }
            } else {
                // Check if there's any OTP record at all for troubleshooting
                $anyOtp = \App\Models\Otp::where('email', $email)->first();
                $message = 'Invalid or expired OTP';
                
                if ($anyOtp) {
                    if ($anyOtp->used) {
                        $message = 'This OTP has already been used. Please request a new OTP.';
                    } else if ($anyOtp->expires_at <= now()) {
                        $message = 'This OTP has expired. Please request a new OTP.';
                    }
                }
                
                return response()->json([
                    'status' => 'error',
                    'message' => $message,
                    'debug_info' => app()->environment('local') ? [
                        'current_time' => now()->toDateTimeString(),
                        'has_any_record' => $anyOtp ? true : false,
                        'record_status' => $anyOtp ? ($anyOtp->used ? 'used' : 'not used') : 'no record',
                        'expiry_status' => $anyOtp ? ($anyOtp->expires_at <= now() ? 'expired' : 'not expired') : 'no record',
                        'cached_otp_exists' => $cachedOtp ? true : false,
                        'cached_otp_matches' => ($cachedOtp && $cachedOtp === $otp)
                    ] : null
                ], 400);
            }
        }
        
        Log::info("Valid OTP found for {$email}. OTP record ID: {$otpRecord->id}");
        
        // IMPORTANT: BEFORE we mark OTP as used, get the data to avoid data loss
        $userData = null;
        $data = null;
        
        if ($otpRecord->data) {
            // Try to parse JSON data
            try {
                $data = json_decode($otpRecord->data, true);
                Log::info("Successfully decoded OTP data for {$email}");
            } catch (\Exception $e) {
                Log::error("Failed to decode JSON data for OTP: " . $e->getMessage());
            }
        } else {
            Log::warning("OTP record for {$email} has no data field");
        }
        
        // Now mark OTP as used
        $otpRecord->update(['used' => true]);
        
        // If we don't have data but need to proceed with verification
        if (!$data || !is_array($data)) {
            Log::error("OTP data is null or invalid for email: {$email}");
            
            // Check if user already exists - this might be a re-verification
            $existingUser = \App\Models\User::where('email', $email)->first();
            if ($existingUser) {
                // Just update the email_verified_at field
                $existingUser->update(['email_verified_at' => now()]);
                
                Log::info("User already exists, marked as verified: {$email}");
                return response()->json([
                    'status' => 'success',
                    'message' => 'Email verified successfully.',
                    'user_existed' => true
                ]);
            }
            
            // No data and no existing user
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid OTP data. Please restart registration.',
                'error' => 'Data format error'
            ], 400);
        }
        
        // Check for required fields
        $requiredFields = ['full_name', 'username', 'phonenumber', 'password'];
        $missingFields = [];
        
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                $missingFields[] = $field;
            }
        }
        
        if (!empty($missingFields)) {
            Log::error("Missing fields in OTP data: " . implode(', ', $missingFields));
            return response()->json([
                'status' => 'error',
                'message' => 'Incomplete registration data. Please try registering again.',
                'error' => 'Missing required fields: ' . implode(', ', $missingFields)
            ], 400);
        }
        
        // Use defaults for optional fields if not present
        $userData = [
            'full_name' => $data['full_name'],
            'username' => $data['username'],
            'email' => $email,
            'phonenumber' => $data['phonenumber'],
            'address' => $data['address'] ?? '',
            'date_of_birth' => $data['date_of_birth'] ?? now()->subYears(18)->format('Y-m-d'),
            'referral_id' => $data['referral_id'] ?? null,
            'profile_image' => $data['profile_image'] ?? 'profile_images/default.png',
            'password' => $data['password'],
            'affiliate_code' => $data['affiliate_code'] ?? $this->generateUniqueRefCode(),
            'email_verified_at' => now()
        ];
        
        try {
            $user = \App\Models\User::create($userData);
            
            // Remove OTP record
            $otpRecord->delete();
            
            // Log the registration
            \App\Models\UserLog::create([
                'user_id' => $user->id,
                'column_name' => 'registration',
                'old_value' => null,
                'new_value' => 'User registered and verified'
            ]);
            
            return response()->json([
                'status' => 'success',
                'message' => 'Email verified and account created.'
            ], 200, ['Content-Type' => 'application/json'], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        } catch (\Exception $e) {
            Log::error("Failed to create user: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create user account.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Accept backup registration data when OTP verification can't find the original data
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function acceptBackupData(Request $request)
    {
        Log::info("Received backup registration data for: {$request->email}");
        
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255',
            'phonenumber' => 'required|string|max:20',
            'date_of_birth' => 'required|date',
            'otp' => 'required|string|size:6',
        ]);
        
        if ($validator->fails()) {
            Log::error("Backup data validation failed:", $validator->errors()->toArray());
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $email = $request->email;
        $otp = $request->otp;
        
        // Verify the OTP from cache first
        $cachedOtp = null;
        try {
            $cachedOtp = \Illuminate\Support\Facades\Cache::store('fallback')->get("otp:{$email}");
        } catch (\Exception $e) {
            Log::error("Cache error in backup verification: " . $e->getMessage());
        }
        
        if ($cachedOtp !== $otp) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid or expired OTP'
            ], 400);
        }
        
        // Generate a unique affiliate code
        $affiliateCode = $this->generateUniqueRefCode();
        
        // Create user from backup data
        try {
            $user = \App\Models\User::create([
                'full_name' => $request->full_name,
                'username' => $request->username,
                'email' => $email,
                'phonenumber' => $request->phonenumber,
                'address' => $request->address ?? '',
                'date_of_birth' => $request->date_of_birth,
                'referral_id' => $request->reference_code ?? null,
                'profile_image' => 'profile_images/default.png', 
                'password' => Hash::make($request->password ?? Str::random(16)), // Use provided or generate random password
                'affiliate_code' => $affiliateCode,
                'email_verified_at' => now()
            ]);
            
            // Log the registration
            \App\Models\UserLog::create([
                'user_id' => $user->id,
                'column_name' => 'registration',
                'old_value' => null,
                'new_value' => 'User registered with backup data'
            ]);
            
            // Clear the cache
            try {
                \Illuminate\Support\Facades\Cache::store('fallback')->forget("otp:{$email}");
            } catch (\Exception $e) {
                Log::error("Failed to clear cache after backup registration: " . $e->getMessage());
            }
            
            return response()->json([
                'status' => 'success',
                'message' => 'Email verified and account created from backup data.'
            ]);
        } catch (\Exception $e) {
            Log::error("Failed to create user from backup data: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create account: ' . $e->getMessage()
            ], 500);
        }
    }
}
