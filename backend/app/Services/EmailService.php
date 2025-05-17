<?php

namespace App\Services;

use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Mail\Message;

class EmailService
{
    /**
     * Send an OTP email to the user
     *
     * @param string $toEmail The recipient email address
     * @param string $otp The OTP code
     * @param string $name The recipient's name
     *
     * @return bool True if the email was sent successfully, false otherwise
     */
    public function sendOtpEmail(string $toEmail, string $otp, string $name = null): bool
    {
        try {
            $subject = 'Your Meta Travel International Verification Code';

            Mail::send([], [], function (Message $message) use ($toEmail, $otp, $name, $subject) {
                $message->to($toEmail)
                    ->subject($subject)
                    ->from(config('mail.from.address'), config('mail.from.name'))
                    ->html($this->getOtpEmailTemplate($otp, $name));
            });

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send OTP email: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send a password reset email
     *
     * @param string $toEmail The recipient email address
     * @param string $resetLink The password reset link
     * @param string $name The recipient's name
     *
     * @return bool True if the email was sent successfully, false otherwise
     */
    public function sendPasswordResetEmail(string $toEmail, string $resetLink, string $name = null): bool
    {
        try {
            $subject = 'Password Reset for Meta Travel International';

            Mail::send([], [], function (Message $message) use ($toEmail, $resetLink, $name, $subject) {
                $message->to($toEmail)
                    ->subject($subject)
                    ->from(config('mail.from.address'), config('mail.from.name'))
                    ->html($this->getPasswordResetEmailTemplate($resetLink, $name));
            });

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send password reset email: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Get the OTP email HTML template
     *
     * @param string $otp The OTP code
     * @param string $name The recipient's name
     *
     * @return string The HTML template
     */
    private function getOtpEmailTemplate(string $otp, string $name = null): string
    {
        $greeting = $name ? "Hello $name," : "Hello,";

        return '
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Email Verification</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    margin: 0;
                    padding: 0;
                    background-color: #f6f6f6;
                }
                .container {
                    width: 100%;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }
                .header {
                    background-color: #6C5DD3;
                    padding: 20px;
                    text-align: center;
                    color: white;
                    border-top-left-radius: 5px;
                    border-top-right-radius: 5px;
                }
                .content {
                    background-color: white;
                    padding: 20px;
                    border-bottom-left-radius: 5px;
                    border-bottom-right-radius: 5px;
                }
                .otp-code {
                    font-size: 32px;
                    font-weight: bold;
                    text-align: center;
                    margin: 30px 0;
                    letter-spacing: 5px;
                    color: #6C5DD3;
                }
                .footer {
                    text-align: center;
                    margin-top: 20px;
                    font-size: 12px;
                    color: #999;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Meta Travel International</h1>
                </div>
                <div class="content">
                    <p>' . $greeting . '</p>
                    <p>Thank you for registering with Meta Travel International. To complete your registration, please use the following verification code:</p>
                    <div class="otp-code">' . $otp . '</div>
                    <p>This code will expire in 15 minutes.</p>
                    <p>If you did not request this code, please disregard this email.</p>
                    <p>Best regards,<br>Meta Travel International Team</p>
                </div>
                <div class="footer">
                    <p>&copy; ' . date('Y') . ' Meta Travel International. All rights reserved.</p>
                    <p>This is an automated message, please do not reply.</p>
                </div>
            </div>
        </body>
        </html>
        ';
    }

    /**
     * Get the password reset email HTML template
     *
     * @param string $resetLink The password reset link
     * @param string $name The recipient's name
     *
     * @return string The HTML template
     */
    private function getPasswordResetEmailTemplate(string $resetLink, string $name = null): string
    {
        $greeting = $name ? "Hello $name," : "Hello,";

        return '
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Password Reset</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    margin: 0;
                    padding: 0;
                    background-color: #f6f6f6;
                }
                .container {
                    width: 100%;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }
                .header {
                    background-color: #6C5DD3;
                    padding: 20px;
                    text-align: center;
                    color: white;
                    border-top-left-radius: 5px;
                    border-top-right-radius: 5px;
                }
                .content {
                    background-color: white;
                    padding: 20px;
                    border-bottom-left-radius: 5px;
                    border-bottom-right-radius: 5px;
                }
                .button {
                    display: inline-block;
                    background-color: #6C5DD3;
                    color: white;
                    text-decoration: none;
                    padding: 12px 24px;
                    border-radius: 4px;
                    margin: 20px 0;
                }
                .footer {
                    text-align: center;
                    margin-top: 20px;
                    font-size: 12px;
                    color: #999;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Meta Travel International</h1>
                </div>
                <div class="content">
                    <p>' . $greeting . '</p>
                    <p>We received a request to reset your password. Click the button below to create a new password:</p>
                    <p style="text-align: center;">
                        <a href="' . $resetLink . '" class="button">Reset Password</a>
                    </p>
                    <p>This link will expire in 1 hour.</p>
                    <p>If you did not request a password reset, please disregard this email.</p>
                    <p>Best regards,<br>Meta Travel International Team</p>
                </div>
                <div class="footer">
                    <p>&copy; ' . date('Y') . ' Meta Travel International. All rights reserved.</p>
                    <p>This is an automated message, please do not reply.</p>
                </div>
            </div>
        </body>
        </html>
        ';
    }
}
