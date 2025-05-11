<?php

namespace App\Services;

use App\Models\Otp;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Cache;

class OtpService
{
    /**
     * Check if OTP table exists
     *
     * @return bool
     */
    private function tableExists(): bool
    {
        return Schema::hasTable('otps');
    }

    /**
     * Generate a new OTP for the given identifier
     *
     * @param string $identifier The email or phone number
     * @param string $type The type of OTP (email, password_reset, etc.)
     * @param int $length Length of the OTP code
     * @param int $validityInMinutes Validity period in minutes
     * 
     * @return string The generated OTP
     */
    public function generate(string $identifier, string $type = 'email', int $length = 6, int $validityInMinutes = 15): string
    {
        // Generate a random numeric OTP of specified length
        $otp = '';
        for ($i = 0; $i < $length; $i++) {
            $otp .= mt_rand(0, 9);
        }

        // Create expiration time
        $validUntil = Carbon::now()->addMinutes($validityInMinutes);
        
        // Store OTP in database or cache based on table availability
        if ($this->tableExists()) {
            // Database storage - preferred method
            
            // Invalidate any existing OTPs for this identifier and type
            Otp::where('identifier', $identifier)
                ->where('type', $type)
                ->where('used', false)
                ->update(['used' => true]);
            
            // Create new OTP record
            Otp::create([
                'identifier' => $identifier,
                'token' => $otp,
                'type' => $type,
                'valid_until' => $validUntil,
            ]);
        } else {
            // Cache storage - fallback method
            $cacheKey = "otp:{$identifier}:{$type}";
            
            // Invalidate existing OTP if any
            Cache::forget($cacheKey);
            
            // Store new OTP in cache
            $otpData = [
                'token' => $otp,
                'used' => false,
                'valid_until' => $validUntil->timestamp
            ];
            
            Cache::put($cacheKey, $otpData, $validUntil);
            
            Log::info("OTP stored in cache. Table 'otps' does not exist.");
        }
        
        return $otp;
    }
    
    /**
     * Verify an OTP for the given identifier
     *
     * @param string $identifier The email or phone number
     * @param string $token The OTP token to verify
     * @param string $type The type of OTP
     * 
     * @return bool True if the OTP is valid, false otherwise
     */
    public function verify(string $identifier, string $token, string $type = 'email'): bool
    {
        if ($this->tableExists()) {
            // Database verification - preferred method
            $otp = Otp::where('identifier', $identifier)
                        ->where('token', $token)
                        ->where('type', $type)
                        ->where('used', false)
                        ->where('valid_until', '>', Carbon::now())
                        ->first();
                        
            if (!$otp) {
                return false;
            }
            
            // Mark OTP as used
            $otp->markAsUsed();
            
            return true;
        } else {
            // Cache verification - fallback method
            $cacheKey = "otp:{$identifier}:{$type}";
            $otpData = Cache::get($cacheKey);
            
            if (!$otpData || 
                $otpData['token'] !== $token || 
                $otpData['used'] || 
                $otpData['valid_until'] < Carbon::now()->timestamp) {
                return false;
            }
            
            // Mark as used
            $otpData['used'] = true;
            Cache::put($cacheKey, $otpData, Carbon::createFromTimestamp($otpData['valid_until']));
            
            return true;
        }
    }
    
    /**
     * Check if user has a valid OTP
     *
     * @param string $identifier The email or phone number
     * @param string $type The type of OTP
     * 
     * @return bool True if a valid OTP exists, false otherwise
     */
    public function hasValidOtp(string $identifier, string $type = 'email'): bool
    {
        if ($this->tableExists()) {
            // Database check - preferred method
            return Otp::where('identifier', $identifier)
                        ->where('type', $type)
                        ->where('used', false)
                        ->where('valid_until', '>', Carbon::now())
                        ->exists();
        } else {
            // Cache check - fallback method
            $cacheKey = "otp:{$identifier}:{$type}";
            $otpData = Cache::get($cacheKey);
            
            return $otpData && 
                !$otpData['used'] && 
                $otpData['valid_until'] > Carbon::now()->timestamp;
        }
    }
    
    /**
     * Get the time remaining (in seconds) until a new OTP can be generated
     * Use this for cooldown period between OTP requests
     *
     * @param string $identifier The email or phone number
     * @param string $type The type of OTP
     * @param int $cooldownInSeconds Cooldown period in seconds
     * 
     * @return int Time remaining in seconds or 0 if no cooldown
     */
    public function getCooldownTimeRemaining(string $identifier, string $type = 'email', int $cooldownInSeconds = 60): int
    {
        if ($this->tableExists()) {
            // Database cooldown check - preferred method
            $latestOtp = Otp::where('identifier', $identifier)
                            ->where('type', $type)
                            ->latest()
                            ->first();
                            
            if (!$latestOtp) {
                return 0;
            }
            
            $createdAt = Carbon::parse($latestOtp->created_at);
            $cooldownEndsAt = $createdAt->addSeconds($cooldownInSeconds);
            
            if (Carbon::now()->lt($cooldownEndsAt)) {
                return Carbon::now()->diffInSeconds($cooldownEndsAt);
            }
        } else {
            // Cache cooldown check - fallback method
            $cacheKey = "otp_cooldown:{$identifier}:{$type}";
            $cooldownTime = Cache::get($cacheKey);
            
            if ($cooldownTime) {
                $cooldownEndsAt = Carbon::createFromTimestamp($cooldownTime);
                
                if (Carbon::now()->lt($cooldownEndsAt)) {
                    return Carbon::now()->diffInSeconds($cooldownEndsAt);
                }
            }
        }
        
        return 0;
    }
}
