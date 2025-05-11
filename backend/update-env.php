<?php

// Script to update .env file with SMTP settings
$envFile = __DIR__ . '/.env';
$envContent = file_get_contents($envFile);

// SMTP settings to add/update
$smtpSettings = [
    'MAIL_MAILER' => 'smtp',
    'MAIL_HOST' => 'email-smtp.us-east-1.amazonaws.com',
    'MAIL_PORT' => '587',
    'MAIL_USERNAME' => 'AKIAV2TTTIWH3SCHUE42',
    'MAIL_PASSWORD' => 'BE50nk0RrCGTrlzN6EThDXdE6Rdm8+n6R+rj6E1D14LV',
    'MAIL_ENCRYPTION' => 'tls',
    'MAIL_FROM_ADDRESS' => 'verify@metatravel.ai',
    'MAIL_FROM_NAME' => '"Meta Travel International"'
];

// Update each setting in the .env file
foreach ($smtpSettings as $key => $value) {
    // Check if the setting already exists
    if (preg_match("/^{$key}=.*$/m", $envContent)) {
        // Replace existing setting
        $envContent = preg_replace("/^{$key}=.*$/m", "{$key}={$value}", $envContent);
    } else {
        // Add new setting
        $envContent .= PHP_EOL . "{$key}={$value}";
    }
}

// Write updated content back to .env file
file_put_contents($envFile, $envContent);

echo "SMTP settings have been updated in .env file." . PHP_EOL;
