<?php

// This script updates the .env file with AWS SES SMTP settings
// Run this script with: php setup-mail-config.php

$envFile = __DIR__ . '/.env';

if (!file_exists($envFile)) {
    echo "Error: .env file not found\n";
    exit(1);
}

$envContent = file_get_contents($envFile);

// Replace mail configuration
$envContent = preg_replace('/MAIL_MAILER=.*/', 'MAIL_MAILER=smtp', $envContent);
$envContent = preg_replace('/MAIL_SCHEME=.*/', 'MAIL_SCHEME=tls', $envContent);
$envContent = preg_replace('/MAIL_HOST=.*/', 'MAIL_HOST=email-smtp.us-east-1.amazonaws.com', $envContent);
$envContent = preg_replace('/MAIL_PORT=.*/', 'MAIL_PORT=587', $envContent);
$envContent = preg_replace('/MAIL_USERNAME=.*/', 'MAIL_USERNAME=AKIAV2TTTIWH3SCHUE42', $envContent);
$envContent = preg_replace('/MAIL_PASSWORD=.*/', 'MAIL_PASSWORD=BE50nk0RrCGTrlzN6EThDXdE6Rdm8+n6R+rj6E1D14LV', $envContent);
$envContent = preg_replace('/MAIL_FROM_ADDRESS=.*/', 'MAIL_FROM_ADDRESS=verify@metatravel.ai', $envContent);
$envContent = preg_replace('/MAIL_FROM_NAME=.*/', 'MAIL_FROM_NAME="MTI Travel Investment"', $envContent);

// Save updated .env file
file_put_contents($envFile, $envContent);

echo "Mail configuration updated successfully!\n";
echo "AWS SES SMTP settings have been configured in your .env file.\n";
