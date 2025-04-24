import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// A service class for handling all local storage operations in the app.
/// 
/// This service provides methods for storing and retrieving data from
/// both SharedPreferences (for non-sensitive data) and FlutterSecureStorage
/// (for sensitive data like auth tokens and user credentials).
class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  
  // Factory constructor
  factory StorageService() => _instance;
  
  // Internal constructor
  StorageService._internal();
  
  // Secure storage instance for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  // Keys for storing user credentials (when "Remember Me" is enabled)
  static const String _emailKey = 'remembered_email';
  static const String _passwordKey = 'remembered_password';
  
  /// Saves user credentials if "Remember Me" is checked
  Future<void> saveUserCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Always save the remember me preference
    await prefs.setBool(AppConstants.rememberMeKey, rememberMe);
    
    if (rememberMe) {
      // Store credentials securely if remember me is enabled
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
    } else {
      // Clear any saved credentials if remember me is disabled
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
    }
  }
  
  /// Retrieves saved user credentials if "Remember Me" was enabled
  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    
    if (rememberMe) {
      final email = await _secureStorage.read(key: _emailKey) ?? '';
      final password = await _secureStorage.read(key: _passwordKey) ?? '';
      return {
        'email': email,
        'password': password,
      };
    }
    
    return {
      'email': '',
      'password': '',
    };
  }
  
  /// Checks if "Remember Me" is enabled
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.rememberMeKey) ?? false;
  }
  
  /// Saves the authentication token
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }
  
  /// Retrieves the authentication token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }
  
  /// Saves user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(userData));
  }
  
  /// Retrieves user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(AppConstants.userKey);
    
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    
    return null;
  }
  
  /// Clears all stored data (for logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Keep remember me setting and saved credentials
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    
    // Clear everything except remember me setting if enabled
    await prefs.clear();
    
    if (rememberMe) {
      await prefs.setBool(AppConstants.rememberMeKey, true);
    } else {
      // Also clear secure storage if remember me is disabled
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
    }
    
    // Always clear the auth token
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }
}
