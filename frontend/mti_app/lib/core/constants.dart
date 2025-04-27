import 'environment.dart';

/// Application constants
class AppConstants {
  // App info
  static const String appName = 'MTI';
  static const String appFullName = 'Meta Travel International';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.mti.travel.investment';
  static const String appDownloadUrl = 'https://mti.travel/app';
  
  // Assets
  static const String logoPath = 'assets/images/mti_logo.png';
  
  // API endpoints - uses Environment class for configuration
  static String get baseUrl => Environment.apiBaseUrl;
  
  // Registration URL
  static String get registrationUrl => Environment.registrationUrl;
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  
  // Cloudflare Turnstile Configuration
  static String get cloudflareTestSiteKey => Environment.captchaSiteKey;
  static String get cloudflareProdSiteKey => ''; // TODO: Add production site key
  static bool get useCloudflareTestKey => Environment.isDevelopment;
  
  // Email Configuration
  static const String smtpHost = 'email-smtp.us-east-1.amazonaws.com';
  static const int smtpPort = 587; // Use 587 for STARTTLS or 465 for TLS Wrapper
  static const String smtpUsername = 'AKIAV2TTTIWH3SCHUE42';
  static const String smtpPassword = 'BE50nk0RrCGTrlzN6EThDXdE6Rdm8+n6R+rj6E1D14LV';
  static const bool smtpRequireTLS = true;
  static const String emailSenderName = 'MTI Support';
  static const String emailFromAddress = 'noreply@mti.travel';
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int resendOtpTimerSeconds = 60;
  static String get testOtp => Environment.testOtp;
}
