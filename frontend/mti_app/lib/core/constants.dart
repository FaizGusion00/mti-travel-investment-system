class AppConstants {
  // App info
  static const String appName = 'MTI';
  static const String appFullName = 'Meta Travel International';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.mti.travel.investment';
  static const String appDownloadUrl = 'https://mti.travel/app';
  
  // Assets
  static const String logoPath = 'assets/images/mti_logo.png';
  
  // API endpoints
  static const String baseUrl = 'https://api.mti.travel';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  
  // Cloudflare Turnstile Configuration
  static const String cloudflareTestSiteKey = '1x00000000000000000000AA'; // Test key
  static const String cloudflareProdSiteKey = ''; // TODO: Add production site key here
  static const bool useCloudflareTestKey = true; // Set to false for production
  
  // Email Configuration
  static const String smtpHost = ''; // TODO: Add SMTP host (e.g., smtp.gmail.com)
  static const int smtpPort = 587; // Common SMTP port
  static const String smtpUsername = ''; // TODO: Add SMTP username/email
  static const String smtpPassword = ''; // TODO: Add SMTP password or app password
  static const String emailSenderName = 'MTI Support';
  static const String emailFromAddress = ''; // TODO: Add sender email address
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int resendOtpTimerSeconds = 60;
}
