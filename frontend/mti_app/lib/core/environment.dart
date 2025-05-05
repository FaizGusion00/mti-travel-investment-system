import 'package:flutter/foundation.dart';

/// Environment configuration class for managing environment-specific settings
class Environment {
  /// Production mode flag
  static bool get isProduction => _getEnvironmentFlag('ENV') == 'production';
  
  /// Development mode flag
  static bool get isDevelopment => !isProduction;
  
  // Local development server IP address
  // IMPORTANT: Change this to your actual machine's IP address when testing on a device
  static const String localServerIP = '10.0.2.2'; // Default for Android emulator
  
  /// API base URL based on environment
  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://panel.metatravel.ai';
    } else {
      // For Android emulator or physical device
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://$localServerIP:8000';
      }
      // For iOS simulator
      else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'http://localhost:8000';
      }
      // For web or other platforms
      else {
        return 'http://localhost:8000';
      }
    }
  }
  
  /// HTTP request timeout in seconds
  static int get requestTimeout {
    return isDevelopment ? 30 : 15; // Longer timeout in development
  }
  
  /// Registration URL based on environment
  static String get registrationUrl {
    if (isProduction) {
      return 'https://panel.metatravel.ai/register';
    } else {
      // For Android emulator
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://$localServerIP:3000/register';
      }
      // For iOS simulator or web
      else {
        return 'http://localhost:3000/register';
      }
    }
  }
  
  
  /// OTP for testing purposes (only in development)
  static String get testOtp {
    return isDevelopment ? '123456' : '';
  }
  
  /// Default captcha site key based on environment
  static String get captchaSiteKey {
    return isDevelopment
        ? '1x00000000000000000000AA' // Test key
        : ''; // TODO: Add production site key
  }

  /// Helper method to get environment variables
  static String _getEnvironmentFlag(String name) {
    // In a real app, you'd use a package like flutter_dotenv
    // or platform-specific code to read environment variables
    
    // For now, hardcode to development for testing
    return const String.fromEnvironment('ENV', defaultValue: 'development');
  }
} 