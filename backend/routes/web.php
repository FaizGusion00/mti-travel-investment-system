<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ApiTesterController;
use App\Http\Controllers\TokenGeneratorController;

Route::get('/', function () {
    return view('welcome-mti');
});

// API Tester Routes
Route::get('/api-tester', [ApiTesterController::class, 'index'])->name('api.tester');

// Token Generator Routes
Route::get('/token-generator', [TokenGeneratorController::class, 'index'])->name('token.generator');
Route::get('/generate-token', [TokenGeneratorController::class, 'generateToken'])->name('generate.token');

// API Documentation Route
Route::get('/api-docs', function () {
    return view('api-docs');
})->name('api.docs');

// Direct test route for API testing
Route::get('/test', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Direct test endpoint is working',
        'timestamp' => now()->toIso8601String(),
    ]);
});

// Authentication Routes
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'admin_login']);
Route::post('/logout', [AuthController::class, 'admin_logout'])->name('logout');

// Admin Dashboard Routes - Protected by admin auth middleware
Route::middleware(['auth:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/users', [DashboardController::class, 'users'])->name('admin.users');
    Route::get('/users/{id}', [DashboardController::class, 'userDetail'])->name('admin.user.detail');
    Route::get('/users/{id}/json', [DashboardController::class, 'getUserJson'])->name('admin.user.json');
    Route::post('/users/{id}/update', [DashboardController::class, 'updateUser'])->name('admin.user.update');
    Route::post('/users/{id}/delete', [DashboardController::class, 'deleteUser'])->name('admin.user.delete');
    Route::get('/logs', [DashboardController::class, 'logs'])->name('admin.logs');

    // Trader management routes
    Route::get('/traders', [DashboardController::class, 'traders'])->name('admin.traders');
    Route::post('/users/{id}/toggle-trader', [DashboardController::class, 'toggleTraderStatus'])->name('admin.toggle.trader');
    Route::post('/users/{id}/update-wallet', [DashboardController::class, 'updateWallet'])->name('admin.update.wallet');
});
