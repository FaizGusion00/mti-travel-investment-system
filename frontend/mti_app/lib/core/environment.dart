import 'package:flutter/foundation.dart';

/// Environment configuration class for managing environment-specific settings
class Environment {
  /// MAIN TOGGLE: Set this to true to use production URLs, false for development
  static bool isProductionUrl = true;
  
  /// Production mode flag (based on build environment)
  static bool get isProduction => _getEnvironmentFlag('ENV') == 'production';
  
  /// Development mode flag (based on build environment)
  static bool get isDevelopment => !isProduction;
  
  // Server URLs
  // static const String _productionApiUrl = 'https://panel.metatravel.ai'; // change for production
  static const String _productionApiUrl = 'http://10.0.2.2:8000'; // change for development
  static const String _productionWebUrl = 'https://panel.metatravel.ai'; // if web then change this guy too according to condition
  
  // Development server URLs
  static const String _developmentWebUrl = 'http://localhost:8000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String _localHostUrl = 'http://localhost:8000';
  
  // Local development server IP address
  // IMPORTANT: Change this to your actual machine's IP address when testing on a device
  static const String localServerIP = '10.0.2.2'; // Default for Android emulator
  
  /// API base URL based on environment toggle
  static String get apiBaseUrl {
    // If production URL is enabled, always return production URL
    if (isProductionUrl) {
      return _productionApiUrl;
    } 
    // Otherwise, return appropriate development URL based on platform
    else {
      // For Android emulator or physical device
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _androidEmulatorUrl;
      }
      // For iOS simulator
      else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _localHostUrl;
      }
      // For web platform
      else if (kIsWeb) {
        // For web in development, we use localhost directly
        return _localHostUrl;
      }
      // For other platforms
      else {
        return _localHostUrl;
      }
    }
  }
  
  /// API v1 base URL - This should be used for all API calls
  static String get apiV1Url {
    return '$apiBaseUrl/api/v1';
  }
  
  /// Web API base URL to handle API calls from web platform
  static String get webApiBaseUrl {
    // Web needs absolute URLs, not relative ones
    return kIsWeb ? _localHostUrl : apiBaseUrl;
  }
  
  /// Web API v1 URL
  static String get webApiV1Url {
    return '$webApiBaseUrl/api/v1';
  }
  
  /// HTTP request timeout in seconds
  static int get requestTimeout {
    return isProductionUrl ? 15 : 30; // Longer timeout in development
  }
  
  /// Registration URL based on environment toggle
  static String get registrationUrl {
    if (isProductionUrl) {
      return _productionWebUrl;
    } else {
      // For Android emulator
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://$localServerIP:3000';
      }
      // For iOS simulator or web
      else {
        return _developmentWebUrl;
      }
    }
  }
  
  /// OTP for testing purposes (only in development)
  static String get testOtp {
    return isProductionUrl ? '' : '123456';
  }
  
  /// Default captcha site key based on environment
  static String get captchaSiteKey {
    return isProductionUrl
        ? '0x4AAAAAABT-8FrRBkgeluJo' // Production key
        : '1x00000000000000000000AA'; // Test key
  }

  /// Helper method to get environment variables (for build configuration)
  static String _getEnvironmentFlag(String name) {
    // In a real app, you'd use a package like flutter_dotenv
    // or platform-specific code to read environment variables
    
    // For now, hardcode to development for testing
    return const String.fromEnvironment('ENV', defaultValue: 'development');
  }
}