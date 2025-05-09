import 'environment.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  
  // API endpoints - CENTRALIZED using Environment class
  
  /// Base URL for the API (without /api/v1)
  static String get baseUrl => Environment.apiBaseUrl;
  
  /// API v1 base URL - ALWAYS use this for all API calls
  static String get apiV1BaseUrl {
    // IMPORTANT: Force use of production URL when isProductionUrl is true
    if (Environment.isProductionUrl) {
      return 'https://panel.metatravel.ai/api/v1';
    }
    
    // For development or different platforms
    return kIsWeb 
        ? Environment.webApiV1Url  // Web-specific URL handling
        : Environment.apiV1Url;    // Mobile URL handling
  }
  
  /// Get environment mode for easy toggling
  static bool get isProductionMode => Environment.isProductionUrl;
  
  /// Set environment mode - allows toggling between production and development
  static set isProductionMode(bool value) {
    Environment.isProductionUrl = value;
  }
  
  /// Registration URL
  static String get registrationUrl => Environment.registrationUrl;
  
  /// Request timeout in seconds
  static int get requestTimeout => Environment.requestTimeout;
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  
  // Cloudflare Turnstile Configuration
  static String get captchaSiteKey => Environment.captchaSiteKey;
  static bool get useTestKeys => !Environment.isProductionUrl;
  
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
