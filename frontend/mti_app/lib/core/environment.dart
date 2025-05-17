import 'package:flutter/foundation.dart';

// Create a web storage interface
abstract class WebStorage {
  String? getItem(String key);
  void setItem(String key, String value);
}

// Implement for web
class BrowserWebStorage implements WebStorage {
  @override
  String? getItem(String key) {
    return null; // Implemented in web_storage_web.dart
  }

  @override
  void setItem(String key, String value) {
    // Implemented in web_storage_web.dart
  }
}

// Implement for non-web (memory-based)
class MemoryWebStorage implements WebStorage {
  final Map<String, String> _storage = {};
  
  @override
  String? getItem(String key) {
    return _storage[key];
  }

  @override
  void setItem(String key, String value) {
    _storage[key] = value;
  }
}

// Factory to get the right implementation
class WebStorageFactory {
  static WebStorage? _instance;
  
  static WebStorage get instance {
    _instance ??= kIsWeb 
        ? BrowserWebStorage() 
        : MemoryWebStorage();
    return _instance!;
  }
}

/// Environment configuration class for managing environment-specific settings
class Environment {
  /// MAIN TOGGLE: Set this to true to use production URLs, false for development
  static bool _isProductionUrl = true;
  
  /// Getter for isProductionUrl that checks web localStorage if in web mode
  static bool get isProductionUrl {
    // For web platform, check localStorage first
    if (kIsWeb) {
      try {
        final storedValue = WebStorageFactory.instance.getItem('isProductionUrl');
        if (storedValue != null) {
          return storedValue == 'true';
        }
      } catch (e) {
        // If localStorage fails, fallback to memory value
        print('Failed to access localStorage: $e');
      }
    }
    return _isProductionUrl;
  }
  
  /// Setter for isProductionUrl that also updates web localStorage
  static set isProductionUrl(bool value) {
    _isProductionUrl = value;
    
    // For web platform, also store in localStorage
    if (kIsWeb) {
      try {
        WebStorageFactory.instance.setItem('isProductionUrl', value.toString());
      } catch (e) {
        // If localStorage fails, just log the error
        print('Failed to store in localStorage: $e');
      }
    }
  }
  
  /// Production mode flag (based on build environment)
  static bool get isProduction => _getEnvironmentFlag('ENV') == 'production';
  
  /// Development mode flag (based on build environment)
  static bool get isDevelopment => !isProduction;
  
  // Server URLs
  static const String _productionApiUrl = 'https://panel.metatravel.ai'; // change for production
  // static const String _productionApiUrl = 'http://10.0.2.2:8000'; // change for development
  static const String _productionWebUrl = 'https://panel.metatravel.ai'; // if web then change this guy too according to condition
  
  // Development server URLs
  static const String _developmentWebUrl = 'http://10.0.2.2:8000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String _localHostUrl = 'http://localhost:8000';
  
  // Local development server IP address
  static const String localServerIP = '10.0.2.2'; // Default for Android emulator
  
  /// API base URL based on environment toggle
  static String get apiBaseUrl {
    // If production URL is enabled, always return production URL for all platforms
    if (isProductionUrl) {
      return _productionApiUrl;
    } 
    // Only use different development URLs if in development mode
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
    if (kIsWeb) {
      return isProductionUrl ? _productionWebUrl : _localHostUrl;
    } else {
      return apiBaseUrl;
    }
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