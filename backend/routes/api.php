<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\NetworkController;
use App\Http\Controllers\API\TestController;
use App\Http\Controllers\API\SimpleTestController;
use App\Http\Controllers\API\TokenGeneratorController;
use App\Http\Controllers\API\WalletController;
use App\Http\Controllers\API\NotificationController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::prefix('v1')->group(function () {
    // Authentication Routes
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/resend-otp', [AuthController::class, 'resendOtp']);
    Route::post('/backup-registration', [AuthController::class, 'acceptBackupData']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
    
    // Public information
    Route::get('/app-info', [UserController::class, 'appInfo']);
    
    // Test endpoints - multiple formats to ensure at least one works
    Route::get('/test', [SimpleTestController::class, 'test']);
    Route::get('test', [SimpleTestController::class, 'test']); // Alternative without leading slash
    Route::get('/get-test-token', [TestController::class, 'getTestToken']);
    
    // Simple test endpoints that don't rely on database
    Route::get('/simple-test', [SimpleTestController::class, 'test']);
    
    // Direct JSON response for testing when controllers might not be accessible
    Route::get('/direct-test', function() {
        return response()->json([
            'status' => 'success',
            'message' => 'API direct test endpoint is working',
            'timestamp' => now()->toIso8601String(),
        ]);
    });
});

// Protected routes
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    // Notification routes
    Route::get('/notifications', ['App\\Http\\Controllers\\API\\NotificationController', 'index']);
    Route::patch('/notifications/{id}/read', ['App\\Http\\Controllers\\API\\NotificationController', 'markAsRead']);
    Route::post('/notifications', ['App\\Http\\Controllers\\API\\NotificationController', 'store']);
    // User profile
    Route::get('/user', [UserController::class, 'getCurrentUser']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Token management
    Route::post('/token/generate', [TokenGeneratorController::class, 'generateToken']);
    Route::post('/token/revoke', [TokenGeneratorController::class, 'revokeTokens']);
    Route::get('/token/info', [TokenGeneratorController::class, 'getTokenInfo']);
    
    // Simple auth test
    Route::get('/auth-test', [SimpleTestController::class, 'authTest']);
    
    // Profile management
    Route::get('/profile', [ProfileController::class, 'getProfile']);
    Route::put('/profile', [ProfileController::class, 'updateProfile']);
    Route::post('/profile/avatar', [ProfileController::class, 'updateAvatar']);
    Route::post('/profile/change-password', [ProfileController::class, 'changePassword']);
    Route::post('/profile/update-email', [ProfileController::class, 'updateEmail']);
    Route::post('/profile/verify-email-update', [ProfileController::class, 'verifyEmailUpdate']);
    Route::post('/profile/update-wallet', [ProfileController::class, 'updateWallet']);
    
    // Network/Referral system
    Route::get('/network', [NetworkController::class, 'getNetwork']);
    Route::get('/network/downline', [NetworkController::class, 'getDownline']);
    Route::get('/network/upline', [NetworkController::class, 'getUpline']);
    Route::get('/network/stats', [NetworkController::class, 'getNetworkStats']);
    Route::get('/network/commissions', [NetworkController::class, 'getCommissions']);
    Route::get('/network/summary', [NetworkController::class, 'getNetworkSummary']);
    
    // Wallet and Trader functionality
    Route::get('/wallet', [WalletController::class, 'getWalletBalances']);
    Route::post('/wallet/transfer', [WalletController::class, 'transferFunds']);
    Route::post('/wallet/swap', [WalletController::class, 'transferBetweenWallets']);
    Route::get('/wallet/transactions', [WalletController::class, 'getTransactionHistory']);
    Route::get('/users/find', [WalletController::class, 'findUser']);
    
    // User management (for admins)
    Route::middleware('admin')->group(function () {
        Route::get('/users', [UserController::class, 'getAllUsers']);
        Route::get('/users/{id}', [UserController::class, 'getUserById']);
        Route::post('/users/{id}', [UserController::class, 'updateUser']);
        Route::put('/users/{id}', [UserController::class, 'updateUser']);
        Route::delete('/users/{id}', [UserController::class, 'deleteUser']);
        Route::get('/users/{id}/logs', [UserController::class, 'getUserLogs']);
        
        // Admin dashboard stats
        Route::get('/stats/users', [UserController::class, 'getUserStats']);
        Route::get('/stats/registrations', [UserController::class, 'getRegistrationStats']);
        Route::get('/stats/activity', [UserController::class, 'getActivityStats']);
    });
});
