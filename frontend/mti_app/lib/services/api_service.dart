import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mti_app/models/user_model.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'] != null ? Map<String, dynamic>.from(json['errors']) : null,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      message: message,
    );
  }
}

class ApiService {
  final http.Client _client = http.Client();
  final StorageService _storageService = StorageService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Get base URL from AppConstants (which now uses Environment)
  String get _baseUrl => AppConstants.baseUrl;

  // Get stored token
  Future<String?> getToken() async {
    return await storage.read(key: AppConstants.tokenKey);
  }

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await storage.write(key: AppConstants.tokenKey, value: token);
  }

  // Remove token (for logout)
  Future<void> removeToken() async {
    await storage.delete(key: AppConstants.tokenKey);
  }

  // Create headers with token
  Future<Map<String, String>> getHeaders({bool withToken = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withToken) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle errors
  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is FormatException) {
      return 'Invalid response format from server.';
    } else if (error is http.ClientException) {
      return 'Connection error. Please try again later.';
    } else if (error is HttpException) {
      return 'HTTP error occurred: ${error.message}';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    return error.toString();
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password, String captchaToken) async {
    try {
      final url = Uri.parse('$_baseUrl/api/v1/login');
      
      print('Making login request to: $url');

      // Add timeout to prevent long waits when server is unreachable
      final response = await http.post(
        url,
        headers: await getHeaders(withToken: false),
        body: jsonEncode({
          'email': email,
          'password': password,
          'captcha_token': captchaToken,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Login response status code: ${response.statusCode}');
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save token if available
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          await saveToken(responseData['data']['token']);
        }
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        // Handle specific error messages from backend
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('Login error: $e');
      String errorMessage = _handleError(e);
      
      // Provide more helpful message for common connection issues
      if (e is SocketException) {
        if (e.message.contains('Connection refused')) {
          errorMessage = 'Could not connect to the server. Please check if the server is running at $_baseUrl';
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/verify-otp'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token if available
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          await saveToken(responseData['data']['token']);
        }
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/logout'),
        headers: await getHeaders(),
      );

      await removeToken();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      // Even if API call fails, still remove token
      await removeToken();
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/profile'),
        headers: await getHeaders(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Update profile with image support
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData, {File? profileImage}) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Use multipart request for file upload
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('$_baseUrl/api/v1/update-profile')
      );
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      userData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add profile image if provided
      if (profileImage != null) {
        final file = await http.MultipartFile.fromPath(
          'profile_image', 
          profileImage.path
        );
        request.files.add(file);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/request-password-reset'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({
          'email': email,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password reset OTP sent',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send password reset OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/reset-password'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password reset successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to reset password',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/resend-otp'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({
          'email': email,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP resent successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }
} 