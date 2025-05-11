<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use App\Models\Admin;
use App\Models\UserLog;
use App\Models\Otp;
use Carbon\Carbon;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phonenumber' => 'required|string|max:20|unique:users',
            'address' => 'nullable|string',
            'date_of_birth' => 'required|date|date_format:Y-m-d',
            'ref_code' => 'nullable|string|max:10',
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $data = $validator->validated();
            $data['password'] = Hash::make($data['password']);

            // Handle profile image upload
            if ($request->hasFile('profile_image')) {
                $image = $request->file('profile_image');
                $imageName = time() . '_' . Str::random(10) . '.' . $image->getClientOriginalExtension();
                $image->storeAs('public/profile_images', $imageName);
                $data['profile_image'] = 'profile_images/' . $imageName;
            } else {
                $data['profile_image'] = 'profile_images/default.png';
            }

            $user = User::create($data);

            // Generate OTP for email verification
            $otp = $this->generateOTP($user->email);
            
            // Send OTP email
            $this->sendOTPEmail($user->email, $otp, $user->full_name);

            return response()->json([
                'status' => 'success',
                'message' => 'User registered successfully. Please verify your email with the OTP sent.',
                'user' => $user,
                'data' => [
                    'otp' => app()->environment('local') ? $otp : null // Only return OTP in local environment for testing
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login user and create token
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Invalid login credentials'
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();

        // Delete existing tokens
        $user->tokens()->delete();

        // Create new token with 3 days expiry
        $token = $user->createToken('auth_token', ['*'], now()->addDays(3))->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token
        ]);
    }

    /**
     * Get authenticated user profile
     */
    public function profile(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'full_name' => 'sometimes|string|max:255',
            'username' => 'sometimes|string|max:255',
            'phonenumber' => 'sometimes|string|max:20|unique:users,phonenumber,' . $user->id,
            'address' => 'nullable|string',
            'date_of_birth' => 'sometimes|date|date_format:Y-m-d',
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        // Handle profile image upload
        if ($request->hasFile('profile_image')) {
            // Delete old image if exists
            if ($user->profile_image) {
                Storage::delete('public/' . $user->profile_image);
            }

            $image = $request->file('profile_image');
            $imageName = time() . '_' . Str::random(10) . '.' . $image->getClientOriginalExtension();
            $image->storeAs('public/profile_images', $imageName);
            $data['profile_image'] = 'profile_images/' . $imageName;
        }

        $user->update($data);


        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user
        ]);
    }

    /**
     * Logout user (Revoke the token)
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Successfully logged out'
        ]);
    }

    /**
     * Admin Login
     */

     public function showLoginForm()
         {
             return view('auth.login');
         }

     public function admin_login(Request $request)
         {
             $credentials = $request->validate([
                 'email' => ['required', 'email'],
                 'password' => ['required'],
             ]);

             // Find admin by email
             $admin = Admin::where('email', $request->email)->first();

             if ($admin && Hash::check($request->password, $admin->password)) {
                 Auth::guard('admin')->login($admin);

                 return redirect()->intended('admin/dashboard');
             }

             return back()->withErrors([
                 'email' => 'The provided credentials do not match our records.',
             ])->onlyInput('email');
         }

         /**
          * Log the user out of the application.
          *
          * @param  \Illuminate\Http\Request  $request
          * @return \Illuminate\Http\RedirectResponse
          */
         public function admin_logout(Request $request)
         {
             Auth::guard('admin')->logout();
             $request->session()->invalidate();
             $request->session()->regenerateToken();

             return redirect('/');
         }

    /**
     * Generate a 6-digit OTP for the given email
     */
    private function generateOTP(string $email): string
    {
        // Generate a random 6-digit OTP
        $otp = str_pad((string)mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);
        
        // Invalidate any existing OTPs for this email
        Otp::where('email', $email)
            ->where('type', 'email_verification')
            ->update(['used' => true]);
        
        // Create a new OTP record
        Otp::create([
            'email' => $email,
            'otp' => $otp,
            'type' => 'email_verification',
            'expires_at' => Carbon::now()->addMinutes(15), // OTP valid for 15 minutes
            'used' => false
        ]);
        
        return $otp;
    }
    
    /**
     * Send OTP email to the user
     */
    private function sendOTPEmail(string $email, string $otp, string $name): void
    {
        try {
            // Send email using Laravel's Mail facade
            Mail::to($email)->send(new \App\Mail\OtpMail($otp, $name));
            
            // Log the OTP for testing purposes in local environment
            if (app()->environment('local')) {
                \Log::info("OTP for {$email}: {$otp}");
            }
        } catch (\Exception $e) {
            // Log the error but don't throw it to avoid disrupting the registration process
            \Log::error("Failed to send OTP email: {$e->getMessage()}");
            
            // Always log the OTP in case of email failure, so we can still test
            \Log::info("OTP for {$email}: {$otp} (Email failed but OTP logged for testing)");
        }
    }
    
    /**
     * Verify OTP for email verification
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
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $email = $request->email;
        $otp = $request->otp;
        
        // Find the latest valid OTP for this email
        $otpRecord = Otp::where('email', $email)
            ->where('otp', $otp)
            ->where('type', 'email_verification')
            ->where('used', false)
            ->where('expires_at', '>', Carbon::now())
            ->latest()
            ->first();
        
        if (!$otpRecord) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid or expired OTP'
            ], 400);
        }
        
        // Mark OTP as used
        $otpRecord->update(['used' => true]);
        
        // Update user's email_verified_at
        $user = User::where('email', $email)->first();
        $user->update(['email_verified_at' => Carbon::now()]);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Email verified successfully'
        ]);
    }
    
    /**
     * Resend OTP for email verification
     */
    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:users,email',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $email = $request->email;
        $user = User::where('email', $email)->first();
        
        // Check if email is already verified
        if ($user->email_verified_at) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email is already verified'
            ], 400);
        }
        
        // Generate and send new OTP
        $otp = $this->generateOTP($email);
        $this->sendOTPEmail($email, $otp, $user->full_name);
        
        return response()->json([
            'status' => 'success',
            'message' => 'OTP resent successfully',
            'data' => [
                'otp' => app()->environment('local') ? $otp : null // Only return OTP in local environment for testing
            ]
        ]);
    }
}
