<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\EmailService;
use App\Services\OtpService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EmailTestController extends Controller
{
    /**
     * Send a test OTP email
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendTestOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'name' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $emailService = new EmailService();
        $otpService = new OtpService();

        // Generate a test OTP
        $otp = mt_rand(100000, 999999);

        // Send email
        $emailSent = $emailService->sendOtpEmail(
            $request->email,
            $otp,
            $request->name ?: null
        );

        return response()->json([
            'status' => 'success',
            'message' => $emailSent ? 'Test OTP email sent successfully' : 'Failed to send test email',
            'data' => [
                'email_sent' => $emailSent,
                'otp' => $otp,
                'smtp_details' => [
                    'host' => config('mail.mailers.smtp.host'),
                    'port' => config('mail.mailers.smtp.port'),
                    'from_address' => config('mail.from.address'),
                    'encryption' => config('mail.mailers.smtp.encryption')
                ]
            ]
        ]);
    }

    /**
     * Send a test email using the AWS SES integration
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function testAwsEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'name' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Send a simple test email directly
            $content = '<!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Test Email</title>
            </head>
            <body>
                <h1>Meta Travel International Email Test</h1>
                <p>This is a test email to verify that the AWS SES SMTP integration is working.</p>
                <p>Time sent: ' . now()->format('Y-m-d H:i:s') . '</p>
            </body>
            </html>';

            \Illuminate\Support\Facades\Mail::send([], [], function ($message) use ($request, $content) {
                $message
                    ->to($request->email)
                    ->subject('Meta Travel International - Email Test')
                    ->from(config('mail.from.address'), config('mail.from.name'))
                    ->html($content);
            });

            return response()->json([
                'status' => 'success',
                'message' => 'Test email sent successfully',
                'data' => [
                    'email' => $request->email,
                    'smtp_details' => [
                        'host' => config('mail.mailers.smtp.host'),
                        'port' => config('mail.mailers.smtp.port'),
                        'from_address' => config('mail.from.address'),
                        'encryption' => config('mail.mailers.smtp.encryption')
                    ]
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send test email',
                'error' => $e->getMessage(),
                'config' => [
                    'mail_driver' => config('mail.default'),
                    'mail_host' => config('mail.mailers.smtp.host'),
                    'mail_port' => config('mail.mailers.smtp.port'),
                    'mail_encryption' => config('mail.mailers.smtp.encryption'),
                    'from_address' => config('mail.from.address'),
                    'from_name' => config('mail.from.name')
                ]
            ], 500);
        }
    }
}
