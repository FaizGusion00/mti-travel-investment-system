import 'package:flutter/foundation.dart';
import 'dart:async';
import 'api_service.dart';
import 'storage_service.dart';
import 'dart:developer' as developer;

/// A service class for handling authentication-related operations
/// such as checking login status, token validation, and session management.
class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  
  // Factory constructor
  factory AuthService() => _instance;
  
  // Internal constructor
  AuthService._internal();
  
  // Services
  final StorageService _storageService = StorageService();
  
  /// Checks if the user is logged in by verifying token existence and validity
  Future<bool> isLoggedIn() async {
    try {
      // Check if token exists
      final token = await _storageService.getAuthToken();
      
      if (token == null || token.isEmpty) {
        _log('No auth token found, user is not logged in');
        return false;
      }
      
      // If token exists, verify its validity by checking with the server
      final isTokenValid = await ApiService.checkAndRefreshTokenIfNeeded();
      
      _log('Token validation check: ${isTokenValid ? 'valid' : 'invalid'}');
      return isTokenValid;
      
    } catch (e) {
      _log('Error checking login status', error: e.toString());
      return false;
    }
  }
  
  /// Performs a logout operation
  Future<bool> logout() async {
    try {
      // Call logout API
      await ApiService.logout();
      
      // Clear local storage
      await _storageService.clearAll();
      
      _log('User logged out successfully');
      return true;
    } catch (e) {
      _log('Error during logout', error: e.toString());
      
      // Even if API call fails, clear local storage
      await _storageService.clearAuthToken();
      await _storageService.clearUserData();
      
      return false;
    }
  }
  
  /// Handles token refresh when needed
  Future<bool> refreshTokenIfNeeded() async {
    try {
      return await ApiService.checkAndRefreshTokenIfNeeded();
    } catch (e) {
      _log('Error refreshing token', error: e.toString());
      return false;
    }
  }
  
  // Debug logging method
  void _log(String message, {String? error}) {
    developer.log(message, name: 'AUTH');
    if (error != null) {
      developer.log('ERROR: $error', name: 'AUTH');
    }
  }
}
