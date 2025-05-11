<?php

/**
 * Meta Travel International - OTP Email Test Script
 * 
 * This script tests the OTP email sending functionality using AWS SES
 * It sends a professionally designed HTML email with a verification code
 */

// Load dependencies
require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\Mail;
use Illuminate\Mail\Message;
use Illuminate\Support\Facades\Log;

// Set console colors for better UI
define('COLOR_GREEN', "\033[32m");
define('COLOR_YELLOW', "\033[33m");
define('COLOR_RED', "\033[31m");
define('COLOR_BLUE', "\033[34m");
define('COLOR_RESET', "\033[0m");

// Print header
echo COLOR_BLUE . "\n╔═══════════════════════════════════════════════════════════╗" . COLOR_RESET . "\n";
echo COLOR_BLUE . "║ " . COLOR_RESET . "           META TRAVEL INTERNATIONAL - EMAIL TEST           " . COLOR_BLUE . " ║" . COLOR_RESET . "\n";
echo COLOR_BLUE . "╚═══════════════════════════════════════════════════════════╝" . COLOR_RESET . "\n\n";

// Bootstrap Laravel
echo COLOR_YELLOW . "[1/3] Bootstrapping Laravel application..." . COLOR_RESET . "\n";
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();
echo COLOR_GREEN . "✓ Laravel bootstrapped successfully" . COLOR_RESET . "\n\n";

// Configure mail settings
echo COLOR_YELLOW . "[2/3] Configuring email settings..." . COLOR_RESET . "\n";
config([
    'mail.default' => 'smtp',
    'mail.mailers.smtp.transport' => 'smtp',
    'mail.mailers.smtp.host' => 'email-smtp.us-east-1.amazonaws.com',
    'mail.mailers.smtp.port' => 587,
    'mail.mailers.smtp.encryption' => 'tls',
    'mail.mailers.smtp.username' => 'AKIAV2TTTIWH3SCHUE42',
    'mail.mailers.smtp.password' => 'BE50nk0RrCGTrlzN6EThDXdE6Rdm8+n6R+rj6E1D14LV',
    'mail.from.address' => 'verify@metatravel.ai',
    'mail.from.name' => 'Meta Travel International',
]);
echo COLOR_GREEN . "✓ Email configuration loaded" . COLOR_RESET . "\n\n";

// Set recipient email
$testEmail = 'gusionrahman12@gmail.com'; // Your email address

// Generate a test OTP
echo COLOR_YELLOW . "[3/3] Generating OTP and sending email..." . COLOR_RESET . "\n";
$otp = str_pad((string)mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);

try {
    // Force queue to sync for immediate sending
    config(['queue.default' => 'sync']);
    
    // Send email with the OtpMail class using the enhanced template
    Mail::to($testEmail)->send(new \App\Mail\OtpMail($otp, 'Test User'));
    
    // Success message
    echo COLOR_GREEN . "\n✓ SUCCESS: Email sent successfully!" . COLOR_RESET . "\n";
    echo "  ├─ Recipient: " . COLOR_BLUE . $testEmail . COLOR_RESET . "\n";
    echo "  ├─ OTP Code: " . COLOR_YELLOW . $otp . COLOR_RESET . "\n";
    echo "  ├─ Sender: verify@metatravel.ai\n";
    echo "  ├─ Template: Professional HTML with Tailwind CSS styling\n";
    echo "  └─ Time: " . date('Y-m-d H:i:s') . "\n\n";
    
    echo "Check your inbox for the verification email.\n";
    echo "If not received, please check your spam folder.\n\n";
    
} catch (Exception $e) {
    // Error message
    echo COLOR_RED . "\n✗ ERROR: Failed to send email!" . COLOR_RESET . "\n";
    echo "  ├─ Error message: " . $e->getMessage() . "\n";
    echo "  └─ Check your SMTP settings and internet connection\n\n";
    
    // Log detailed error for debugging
    Log::error("Email sending failed: " . $e->getMessage());
    Log::error($e->getTraceAsString());
}

echo COLOR_BLUE . "\n╔═══════════════════════════════════════════════════════════╗" . COLOR_RESET . "\n";
echo COLOR_BLUE . "║ " . COLOR_RESET . "                      TEST COMPLETED                      " . COLOR_BLUE . " ║" . COLOR_RESET . "\n";
echo COLOR_BLUE . "╚═══════════════════════════════════════════════════════════╝" . COLOR_RESET . "\n";
