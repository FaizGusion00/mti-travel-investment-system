import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/environment.dart';
import 'storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mti_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      errors:
          json['errors'] != null
              ? Map<String, dynamic>.from(json['errors'])
              : null,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(success: false, message: message);
  }
}

class ApiService {
  final http.Client _client = http.Client();
  final StorageService _storageService = StorageService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  /// Centralized API V1 URL - Always use this for all API calls
  static String get baseUrl => AppConstants.apiV1BaseUrl;
  
  /// Storage key for authentication token
  static const String tokenKey = 'auth_token';
  
  /// Get the current environment mode (production or development)
  static bool get isProduction => AppConstants.isProductionMode;
  
  /// Toggle between production and development modes
  static void setProductionMode(bool value) {
    AppConstants.isProductionMode = value;
    _log('API environment switched to ${value ? "PRODUCTION" : "DEVELOPMENT"}');
  }

  // Debug logging method
  static void _log(String message, {String? error}) {
    if (kDebugMode) {
      print('MTI_API: $message');
      if (error != null) {
        print('MTI_API_ERROR: $error');
      }
    }
  }

  // Get base URL from AppConstants (which now uses Environment)
  String get _baseUrl => AppConstants.baseUrl;

  // Get stored token
  static Future<String?> getToken() async {
    _log('Getting token from storage');
    try {
      // Use StorageService to get token from secure storage
      final StorageService storageService = StorageService();
      final token = await storageService.getAuthToken();

      if (token != null && token.isNotEmpty) {
        _log('Token retrieved successfully from secure storage');
        return token;
      } else {
        _log('No token found in secure storage');
        return null;
      }
    } catch (e) {
      _log('Error retrieving token', error: e.toString());
      return null;
    }
  }

  // Save token
  static Future<void> saveToken(String token) async {
    try {
      // Use StorageService to save token to secure storage
      final StorageService storageService = StorageService();
      await storageService.saveAuthToken(token);
      _log('Token saved successfully to secure storage');
    } catch (e) {
      _log('Error saving token', error: e.toString());
    }
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
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

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? captchaToken,
  }) async {
    _log('Attempting login for: $email');

    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
    };

    // Add captcha token if provided
    if (captchaToken != null) {
      _log('Including captcha token in login request');
      requestBody['cf-turnstile-response'] = captchaToken;
    }

    try {
      // Get the correct API URL from centralized constants
      final String apiUrl = '${AppConstants.apiV1BaseUrl}/login';
      _log('Using centralized API URL config: $apiUrl');
      _log('Sending login request to: $apiUrl');

      // Create a client with timeout
      final client = http.Client();
      try {
        // Send request with timeout
        final response = await client
            .post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestBody),
            )
            .timeout(Duration(seconds: Environment.requestTimeout));

        _log('Login response status code: ${response.statusCode}');
        _log('Login response body: ${response.body}');

        // Check if the response is JSON by looking at content-type header or trying to decode
        bool isJsonResponse = false;
        Map<String, dynamic> responseData = {};

        try {
          // First check the content-type header
          String? contentType = response.headers['content-type'];
          isJsonResponse =
              contentType != null && contentType.contains('application/json');

          // Try to decode the JSON regardless of content-type
          if (response.body.isNotEmpty) {
            responseData = json.decode(response.body);
            isJsonResponse = true; // If we got here, it's valid JSON
          }
        } catch (e) {
          // If we can't decode as JSON, log the first 100 characters of the response
          String responsePreview =
              response.body.length > 100
                  ? '${response.body.substring(0, 100)}...'
                  : response.body;
          _log(
            'Response is not valid JSON',
            error: 'Format error: $e. Response preview: $responsePreview',
          );
          isJsonResponse = false;
        }

        if (response.statusCode == 200 && isJsonResponse) {
          // Extract token from the response based on backend structure
          String? token;

          if (responseData.containsKey('token')) {
            // Direct token in response
            token = responseData['token'];
            _log('Login successful, token received');
          } else if (responseData.containsKey('data') &&
              responseData['data'] is Map &&
              responseData['data'].containsKey('token')) {
            // Token in data object
            token = responseData['data']['token'];
            _log('Login successful, token received from data');
          } else {
            _log(
              'Login response contains no token',
              error: 'Token missing in response',
            );
          }

          // Save token if found
          if (token != null) {
            await saveToken(token);
            _log('Token saved successfully');
          }

          return {
            'success': true,
            'message': responseData['message'] ?? 'Login successful',
            'token': token,
            'user': responseData['user'] ?? responseData['data']?['user'],
          };
        } else {
          // Handle error responses (both JSON and non-JSON)
          String errorMessage;
          if (isJsonResponse && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            // For non-JSON responses or JSON without message
            switch (response.statusCode) {
              case 401:
                errorMessage =
                    'Invalid credentials. Please check your email and password.';
                break;
              case 403:
                errorMessage = 'Account is locked or requires verification.';
                break;
              case 422:
                errorMessage = 'Validation failed. Please check your input.';
                break;
              case 500:
                errorMessage = 'Server error. Please try again later.';
                break;
              default:
                errorMessage =
                    'Login failed. Status code: ${response.statusCode}';
            }
          }

          _log(
            'Login failed with status ${response.statusCode}',
            error: errorMessage,
          );
          return {
            'success': false,
            'message': errorMessage,
            'status_code': response.statusCode,
            'errors': isJsonResponse ? responseData['errors'] : null,
          };
        }
      } finally {
        // Always close the client to prevent resource leaks
        client.close();
      }
    } catch (e) {
      String errorMessage = 'Login failed';

      if (e is SocketException) {
        errorMessage =
            'Cannot connect to server. Please check your internet connection.';
        _log('Socket exception during login', error: e.toString());
      } else if (e is TimeoutException) {
        errorMessage = 'Connection timed out. Server may be unavailable.';
        _log('Timeout exception during login', error: e.toString());
      } else if (e is FormatException) {
        errorMessage = 'Invalid response format from server.';
        _log('Format exception during login', error: e.toString());
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
        _log('Exception during login', error: e.toString());
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  // Get profile
  static Future<Map<String, dynamic>> getProfile() async {
    _log('Getting user profile');

    final token = await getToken();
    if (token == null) {
      _log('Get profile failed', error: 'Not authenticated');
      return {'success': false, 'message': 'Not authenticated'};
    }

    final client = http.Client();
    try {
      // Use centralized API URL for consistency
      final apiUrl = '${AppConstants.apiV1BaseUrl}/user';
      _log('Using centralized API URL config for profile: $apiUrl');
      _log('Sending profile request to: $apiUrl');

      final response = await client
          .get(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      _log('Profile response status code: ${response.statusCode}');

      // Check if the response is JSON by looking at content-type header or trying to decode
      bool isJsonResponse = false;
      Map<String, dynamic> responseData = {};

      try {
        // First check the content-type header
        String? contentType = response.headers['content-type'];
        isJsonResponse =
            contentType != null && contentType.contains('application/json');

        // Try to decode the JSON regardless of content-type
        if (response.body.isNotEmpty) {
          responseData = json.decode(response.body);
          isJsonResponse = true; // If we got here, it's valid JSON
        }
      } catch (e) {
        // If we can't decode as JSON, log the first 100 characters of the response
        String responsePreview =
            response.body.length > 100
                ? '${response.body.substring(0, 100)}...'
                : response.body;
        _log(
          'Response is not valid JSON',
          error: 'Format error: $e. Response preview: $responsePreview',
        );
        isJsonResponse = false;
      }

      if (response.statusCode == 200 && isJsonResponse) {
        _log('Profile retrieved successfully');

        // Extract user data from response (could be at different locations)
        final userData =
            responseData['user'] ?? responseData['data']?['user'] ?? {};

        // Get the avatar URL from the response
        // It could be directly in responseData or in data.avatar_url
        String avatarUrl =
            responseData['avatar_url'] ??
            responseData['data']?['avatar_url'] ??
            userData['avatar_url'] ??
            '';

        // For web platform, ensure the image URL is a complete URL
        if (kIsWeb && avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
          // If the URL is relative, prepend the backend URL from environment settings
          final baseBackendUrl = AppConstants.baseUrl;
          _log('Using base URL for profile image: $baseBackendUrl');

          // If the URL already starts with a slash, don't add another one
          if (avatarUrl.startsWith('/')) {
            avatarUrl = '$baseBackendUrl$avatarUrl';
          } else {
            avatarUrl = '$baseBackendUrl/$avatarUrl';
          }
          _log('Formatted profile image URL for web: $avatarUrl');
        }

        _log('Profile image URL in response: $avatarUrl');

        return {
          'success': true,
          'user': userData,
          'avatar_url': avatarUrl,
          'message':
              responseData['message'] ?? 'Profile retrieved successfully',
        };
      } else {
        // Handle error responses (both JSON and non-JSON)
        String errorMessage;
        if (isJsonResponse && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else {
          // For non-JSON responses or JSON without message
          switch (response.statusCode) {
            case 401:
              errorMessage = 'Authentication failed. Please log in again.';
              break;
            case 403:
              errorMessage =
                  'You do not have permission to access this resource.';
              break;
            case 404:
              errorMessage = 'Profile not found.';
              break;
            case 500:
              errorMessage = 'Server error. Please try again later.';
              break;
            default:
              errorMessage =
                  'Failed to get profile. Status code: ${response.statusCode}';
          }
        }

        _log('Failed to get profile', error: errorMessage);
        return {
          'success': false,
          'message': errorMessage,
          'status_code': response.statusCode,
          'errors': isJsonResponse ? responseData['errors'] : null,
        };
      }
    } catch (e) {
      String errorMessage = 'Failed to get profile';

      if (e is SocketException) {
        errorMessage =
            'Cannot connect to server. Please check your internet connection.';
        _log('Socket exception during profile retrieval', error: e.toString());
      } else if (e is TimeoutException) {
        errorMessage = 'Connection timed out. Server may be unavailable.';
        _log('Timeout exception during profile retrieval', error: e.toString());
      } else if (e is FormatException) {
        errorMessage = 'Invalid response format from server.';
        _log('Format exception during profile retrieval', error: e.toString());
      } else {
        errorMessage = 'Failed to get profile: ${e.toString()}';
        _log('Exception during profile retrieval', error: e.toString());
      }

      return {'success': false, 'message': errorMessage};
    } finally {
      client.close();
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    _log('Updating profile with data: $data');
    final token = await getToken();
    if (token == null) {
      _log('Update profile failed', error: 'Not authenticated');
      throw Exception('Not authenticated');
    }

    try {
      // Use centralized API URL for consistency
      final apiUrl = '${AppConstants.apiV1BaseUrl}/profile';
      _log('Using centralized API URL config for profile update: $apiUrl');
      _log('Sending profile update request to: $apiUrl');

      final client = http.Client();
      try {
        final response = await client
            .put(
              Uri.parse(apiUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json', // Ensure we request JSON response
              },
              body: json.encode(data),
            )
            .timeout(Duration(seconds: Environment.requestTimeout));

        _log('Profile update response status code: ${response.statusCode}');
        _log('Profile update response body: ${response.body}');

        // Handle non-JSON responses
        if (response.body.trim().isEmpty) {
          _log('Empty response from server', error: 'Empty response');
          throw Exception('Server returned an empty response');
        }

        // Check if response is HTML instead of JSON (indicates server error)
        if (response.body.trim().toLowerCase().startsWith('<!doctype') ||
            response.body.trim().toLowerCase().startsWith('<html')) {
          _log(
            'Server returned HTML error page instead of JSON',
            error: 'Invalid response format',
          );
          throw Exception(
            'Server encountered an error. Please try again later.',
          );
        }

        try {
          final responseData = json.decode(response.body);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            _log('Profile updated successfully');
            return responseData;
          } else {
            final errorMessage =
                responseData['message'] ?? 'Failed to update profile';
            _log('Failed to update profile', error: errorMessage);
            throw Exception(errorMessage);
          }
        } catch (e) {
          if (e is FormatException) {
            _log(
              'Server returned invalid JSON',
              error: 'FormatException: ${e.toString()}',
            );
            _log('Response body: ${response.body}');
            throw Exception(
              'Server returned an invalid response format. Please try again later.',
            );
          }
          rethrow;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      _log('Exception during profile update', error: e.toString());
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Update profile image
  static Future<Map<String, dynamic>> updateProfileImage(
    String imagePath,
  ) async {
    _log('Uploading profile image: $imagePath');
    final token = await getToken();
    if (token == null) {
      _log('Upload profile image failed', error: 'Not authenticated');
      throw Exception('Not authenticated');
    }

    try {
      // Use centralized API URL for consistency
      final apiUrl = '${AppConstants.apiV1BaseUrl}/profile/avatar';
      _log(
        'Using centralized API URL config for profile image update: $apiUrl',
      );
      _log('Sending image upload request to: $apiUrl');

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] =
          'application/json'; // Ensure we get JSON response

      // Add file under both field names for compatibility
      // The ProfileController accepts either 'avatar' or 'profile_image'
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar', // field name used in the API
          imagePath,
          filename: imagePath.split('/').last,
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image', // alternate field name
          imagePath,
          filename: imagePath.split('/').last,
        ),
      );

      _log('Sending multipart request with image file');
      final streamedResponse = await request.send().timeout(
        Duration(seconds: Environment.requestTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      _log('Image upload response status code: ${response.statusCode}');
      _log('Image upload response body: ${response.body}');

      // Handle non-JSON responses
      if (response.body.trim().isEmpty) {
        _log('Empty response from server', error: 'Empty response');
        throw Exception('Server returned an empty response');
      }

      // Check if response is HTML instead of JSON (indicates server error)
      if (response.body.trim().toLowerCase().startsWith('<!doctype') ||
          response.body.trim().toLowerCase().startsWith('<html')) {
        _log(
          'Server returned HTML error page instead of JSON',
          error: 'Invalid response format',
        );
        throw Exception('Server encountered an error. Please try again later.');
      }

      try {
        final responseData = json.decode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          _log('Profile image uploaded successfully');
          return responseData;
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to upload profile image';
          _log('Failed to upload profile image', error: errorMessage);
          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is FormatException) {
          _log('Invalid JSON response from server', error: e.toString());
          _log('Response body: ${response.body}');
          throw Exception(
            'Server returned an invalid response format. Please try again later.',
          );
        }
        rethrow;
      }
    } catch (e) {
      _log('Exception during profile image upload', error: e.toString());
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await removeToken();
    } else {
      throw Exception(json.decode(response.body)['message'] ?? 'Logout failed');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/verify-otp'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token if available
        if (responseData['data'] != null &&
            responseData['data']['token'] != null) {
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
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/request-password-reset'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({'email': email}),
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
          'message':
              responseData['message'] ?? 'Failed to send password reset OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
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
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/resend-otp'),
        headers: await getHeaders(withToken: false),
        body: jsonEncode({'email': email}),
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
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Generate new token
  static Future<Map<String, dynamic>> generateNewToken() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/token/generate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception(
        json.decode(response.body)['message'] ?? 'Failed to generate new token',
      );
    }
  }

  // Get token info
  static Future<Map<String, dynamic>> getTokenInfo() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      // Use the correct API path format
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/token/info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Try a simple auth test if token info endpoint fails
        final authTestResponse = await http.get(
          Uri.parse('$baseUrl/api/v1/auth-test'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (authTestResponse.statusCode == 200) {
          // If auth test succeeds, token is valid but token info endpoint might be missing
          return {
            'status': 'success',
            'token_info': {
              'expires_at':
                  DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            },
          };
        } else {
          throw Exception(
            json.decode(response.body)['message'] ?? 'Failed to get token info',
          );
        }
      }
    } catch (e) {
      _log('Error getting token info: $e');
      throw Exception('Failed to get token info: $e');
    }
  }

  // Revoke all tokens
  static Future<void> revokeAllTokens() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/token/revoke'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await removeToken();
    } else {
      throw Exception(
        json.decode(response.body)['message'] ?? 'Failed to revoke tokens',
      );
    }
  }

  // Get wallet balances
  static Future<Map<String, dynamic>> getWalletBalances() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      // Get the correct API URL from centralized constants
      final String apiUrl = '${AppConstants.apiV1BaseUrl}/wallet';
      _log('Using centralized API URL config for wallet: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return {'status': 'success', 'data': responseData['data']};
        } else {
          return {
            'status': 'error',
            'message':
                responseData['message'] ?? 'Failed to get wallet balances',
          };
        }
      } else {
        return {
          'status': 'error',
          'message':
              'Failed to get wallet balances. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('Error getting wallet balances', error: e.toString());
      return {
        'status': 'error',
        'message': 'Failed to get wallet balances: $e',
      };
    }
  }

  // Find users for transfer - can search by ID, name, email, or phone number
  static Future<Map<String, dynamic>> findUsers(String query) async {
    try {
      // Validate query length
      if (query.trim().length < 2) {
        return {
          'success': false,
          'message': 'Please enter at least 2 characters to search',
        };
      }

      _log('Searching for users with query: $query');
      final token = await getToken();
      if (token == null) {
        _log('Find users failed', error: 'Not authenticated');
        return {'success': false, 'message': 'Not authenticated'};
      }

      final encodedQuery = Uri.encodeComponent(query.trim());

      // Log the full URL for debugging
      final url =
          '${AppConstants.baseUrl}/api/v1/users/find?query=$encodedQuery';
      _log('Search URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      _log('Find users response status code: ${response.statusCode}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _log('Users found successfully');
        return {
          'success': true,
          'users': responseData['data'] ?? responseData['users'] ?? [],
          'message': responseData['message'] ?? 'Users found successfully',
        };
      } else {
        _log(
          'Failed to find users',
          error:
              'Status code: ${response.statusCode}, message: ${responseData['message'] ?? 'Unknown error'}',
        );
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to find users. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred.';
      if (e is SocketException) {
        errorMessage =
            'Failed to connect to the server. Please check your internet connection.';
      } else if (e is TimeoutException) {
        errorMessage =
            'Request timed out. Please check your internet connection or try again later.';
      }

      _log('Error finding users', error: e.toString());
      return {'success': false, 'message': errorMessage};
    }
  }

  // Transfer funds - supports multiple recipient identifiers (email, phone, ID)
  static Future<Map<String, dynamic>> transferFunds({
    required String
    recipientIdentifier, // Can be email, phone number, or user ID
    required double amount,
    String? notes,
    String identifierType = 'auto', // 'auto', 'email', 'phone', 'id'
  }) async {
    try {
      _log(
        'Transferring funds to $recipientIdentifier, amount: $amount, type: $identifierType',
      );
      final token = await getToken();
      if (token == null) {
        _log('Transfer funds failed', error: 'Not authenticated');
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Determine the identifier type if set to auto
      String actualIdentifierType = identifierType;
      if (identifierType == 'auto') {
        // Simple validation to guess the identifier type
        if (recipientIdentifier.contains('@')) {
          actualIdentifierType = 'email';
        } else if (recipientIdentifier.startsWith('+') ||
            recipientIdentifier.length >= 10 &&
                int.tryParse(
                      recipientIdentifier.replaceAll(RegExp(r'[\s-]'), ''),
                    ) !=
                    null) {
          actualIdentifierType = 'phone';
        } else if (int.tryParse(recipientIdentifier) != null) {
          actualIdentifierType = 'id';
        } else {
          actualIdentifierType = 'email'; // Default to email if can't determine
        }
      }

      // Build the request body based on the identifier type
      final Map<String, dynamic> requestBody = {
        'amount': amount,
        'wallet_type':
            'cash_wallet', // Must match exact value expected by backend
      };

      // Add the appropriate identifier field based on type
      switch (actualIdentifierType) {
        case 'email':
          requestBody['recipient_email'] = recipientIdentifier;
          break;
        case 'phone':
          requestBody['recipient_phone'] =
              recipientIdentifier; // Must match the parameter name in backend validation
          break;
        case 'id':
          requestBody['recipient_id'] = recipientIdentifier;
          break;
        default:
          requestBody['recipient_email'] = recipientIdentifier;
      }

      if (notes != null && notes.isNotEmpty) {
        requestBody['notes'] = notes;
      }

      _log('Transfer request body: $requestBody');

      // Log the full URL for debugging
      final url = '${AppConstants.baseUrl}/api/v1/wallet/transfer';
      _log('Transfer URL: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      _log('Transfer funds response status code: ${response.statusCode}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _log('Funds transferred successfully');
        return {
          'success': true,
          'message': responseData['message'] ?? 'Transfer successful',
          'data': responseData['data'],
        };
      } else {
        _log(
          'Failed to transfer funds',
          error:
              'Status code: ${response.statusCode}, message: ${responseData['message'] ?? 'Unknown error'}',
        );
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to transfer funds. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred.';
      if (e is SocketException) {
        errorMessage =
            'Failed to connect to the server. Please check your internet connection.';
      } else if (e is TimeoutException) {
        errorMessage =
            'Request timed out. Please check your internet connection or try again later.';
      }

      _log('Error transferring funds', error: e.toString());
      return {'success': false, 'message': errorMessage};
    }
  }
  
  // Transfer funds between user's own wallets (internal transfer)
  static Future<Map<String, dynamic>> transferBetweenWallets({
    required String sourceWallet,
    required String destinationWallet,
    required double amount,
    String? notes,
  }) async {
    try {
      _log(
        'Transferring $amount between wallets: $sourceWallet → $destinationWallet',
      );
      final token = await getToken();
      if (token == null) {
        _log('Internal transfer failed', error: 'Not authenticated');
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Build request body for internal transfer
      final Map<String, dynamic> requestBody = {
        'source_wallet': sourceWallet,
        'destination_wallet': destinationWallet,
        'amount': amount,
      };

      if (notes != null && notes.isNotEmpty) {
        requestBody['notes'] = notes;
      }

      _log('Internal transfer request body: $requestBody');

      // Log the full URL for debugging
      final url = '${AppConstants.baseUrl}/api/v1/wallet/swap';
      _log('Internal transfer URL: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      _log('Internal transfer response status code: ${response.statusCode}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _log('Funds swapped successfully between wallets');
        return {
          'success': true,
          'message': responseData['message'] ?? 'Internal transfer successful',
          'data': responseData['data'],
        };
      } else {
        _log(
          'Failed to swap funds between wallets',
          error:
              'Status code: ${response.statusCode}, message: ${responseData['message'] ?? 'Unknown error'}',
        );
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to swap funds. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred.';
      if (e is SocketException) {
        errorMessage =
            'Failed to connect to the server. Please check your internet connection.';
      } else if (e is TimeoutException) {
        errorMessage =
            'Request timed out. Please check your internet connection or try again later.';
      }

      _log('Error in internal wallet transfer', error: e.toString());
      return {'success': false, 'message': errorMessage};
    }
  }

  // Get wallet transactions
  static Future<Map<String, dynamic>> getWalletTransactions({
    String walletType = 'cash_wallet',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = {
        'wallet_type': walletType,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/api/v1/wallet/transactions',
      ).replace(queryParameters: queryParams);

      _log('Getting wallet transactions from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          _log('Successfully retrieved transactions');
          return {'status': 'success', 'data': responseData['data']};
        } else {
          _log(
            'Failed to get transactions with success status',
            error: responseData['message'],
          );
          return {
            'status': 'error',
            'message':
                responseData['message'] ?? 'Failed to get wallet transactions',
          };
        }
      } else {
        var errorMessage =
            'Failed to get wallet transactions. Status code: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore JSON decode errors on error responses
        }

        _log('Failed to get transactions', error: errorMessage);
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      _log('Exception getting wallet transactions', error: e.toString());
      return {
        'status': 'error',
        'message': 'Failed to get wallet transactions: $e',
      };
    }
  }

  // Get network data with specified levels
  static Future<Map<String, dynamic>> getNetwork({int levels = 5}) async {
    _log('Getting network data with $levels levels');
    try {
      final token = await getToken();
      if (token == null) {
        _log('No token found for network request');
        return {'status': 'error', 'message': 'Authentication token required'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/network?levels=$levels'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _log('Successfully retrieved network data');
        
        // Process the network data into a more usable format
        final userData = responseData['data']['user'];
        final downlines = responseData['data']['downlines'] ?? [];
        
        // Create root node structure for the current user
        final Map<String, dynamic> networkTree = {
          'id': userData['affiliate_code'] ?? '',
          'name': userData['full_name'] ?? 'You',
          'level': 'Level 0',
          'downlines': downlines.length,
          'isActive': true,
          'status': 'Active',
          'joinDate': _formatDate(userData['created_at']),
          'children': _processDownlines(downlines, 1),
        };
        
        return {'status': 'success', 'data': networkTree};
      } else {
        var errorMessage = 'Failed to get network data. Status code: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore JSON decode errors on error responses
        }

        _log('Failed to get network data', error: errorMessage);
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      _log('Exception getting network data', error: e.toString());
      return {'status': 'error', 'message': 'Failed to get network data: $e'};
    }
  }
  
  // Helper method to process downlines recursively
  static List<Map<String, dynamic>> _processDownlines(List<dynamic> downlines, int level) {
    List<Map<String, dynamic>> result = [];
    
    for (var downline in downlines) {
      final children = downline['children'] ?? [];
      
      result.add({
        'id': downline['affiliate_code'] ?? '',
        'name': downline['full_name'] ?? '',
        'level': 'Level $level',
        'downlines': children.length,
        'isActive': true, // Default to active, can be updated if status is available
        'status': 'Active', // Default status
        'joinDate': _formatDate(downline['created_at']),
        'children': _processDownlines(children, level + 1),
      });
    }
    
    return result;
  }
  
  // Helper to format date
  static String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      // Format as 'MMM d, yyyy'
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Get network statistics
  static Future<Map<String, dynamic>> getNetworkStats() async {
    _log('Getting network statistics');
    try {
      final token = await getToken();
      if (token == null) {
        _log('No token found for network stats request');
        return {'status': 'error', 'message': 'Authentication token required'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/network/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _log('Successfully retrieved network statistics');
        return {'status': 'success', 'data': responseData['data']};
      } else {
        var errorMessage = 'Failed to get network statistics. Status code: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore JSON decode errors on error responses
        }

        _log('Failed to get network statistics', error: errorMessage);
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      _log('Exception getting network statistics', error: e.toString());
      return {'status': 'error', 'message': 'Failed to get network statistics: $e'};
    }
  }

  // Get simplified network summary (just direct referrals and total members)
  static Future<Map<String, dynamic>> getNetworkSummary() async {
    _log('Getting simplified network summary');
    try {
      final token = await getToken();
      if (token == null) {
        _log('No token found for network summary request');
        return {'status': 'error', 'message': 'Authentication token required'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/network/summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _log('Successfully retrieved network summary: ${responseData['data']}');
        return {'status': 'success', 'data': responseData['data']};
      } else {
        var errorMessage = 'Failed to get network summary. Status code: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore JSON decode errors on error responses
        }

        _log('Failed to get network summary', error: errorMessage);
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      _log('Exception getting network summary', error: e.toString());
      return {'status': 'error', 'message': 'Failed to get network summary: $e'};
    }
  }

  // Get commissions data
  static Future<Map<String, dynamic>> getCommissions() async {
    _log('Getting commission data');
    try {
      final token = await getToken();
      if (token == null) {
        _log('No token found for commissions request');
        return {'status': 'error', 'message': 'Authentication token required'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/network/commissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _log('Successfully retrieved commission data');
        return {'status': 'success', 'data': responseData['data']};
      } else {
        var errorMessage = 'Failed to get commission data. Status code: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore JSON decode errors on error responses
        }

        _log('Failed to get commission data', error: errorMessage);
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      _log('Exception getting commission data', error: e.toString());
      return {'status': 'error', 'message': 'Failed to get commission data: $e'};
    }
  }

  // Get current user's affiliate code
  static Future<String?> getUserAffiliateCode() async {
    _log('Getting user affiliate code from profile');
    try {
      final profileResponse = await getProfile();
      if (profileResponse['success'] == true && profileResponse['user'] != null) {
        final userData = profileResponse['user'];
        final affiliateCode = userData['affiliate_code']?.toString() ?? '';
        _log('Successfully retrieved affiliate code: $affiliateCode');
        return affiliateCode;
      } else {
        _log('Failed to get affiliate code', error: profileResponse['message']);
        return null;
      }
    } catch (e) {
      _log('Exception getting affiliate code', error: e.toString());
      return null;
    }
  }

  // Check token validity and refresh if needed
  static Future<bool> checkAndRefreshTokenIfNeeded() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        _log('No token found');
        return false;
      }

      // First try a simple auth test which is more likely to exist
      try {
        final authTestResponse = await http.get(
          Uri.parse('$baseUrl/api/v1/auth-test'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (authTestResponse.statusCode == 200) {
          _log('Auth test passed, token is valid');
          return true;
        }
      } catch (authTestError) {
        _log(
          'Auth test failed, trying profile endpoint',
          error: authTestError.toString(),
        );
      }

      // If auth test fails or throws, try profile endpoint directly
      // This is the most reliable way to check token validity
      try {
        final profileResponse = await http.get(
          Uri.parse('$baseUrl/api/v1/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (profileResponse.statusCode == 200) {
          _log('Profile endpoint check passed, token is valid');
          return true;
        }
      } catch (profileError) {
        _log(
          'Profile check failed, trying token info',
          error: profileError.toString(),
        );
      }

      // As a last resort, try token info
      try {
        final tokenInfo = await getTokenInfo();
        if (tokenInfo['status'] == 'success') {
          if (tokenInfo['token_info'].containsKey('expires_at')) {
            final expiresAt = DateTime.parse(
              tokenInfo['token_info']['expires_at'],
            );

            // If token expires in less than 1 day, generate a new one
            if (expiresAt.difference(DateTime.now()).inDays < 1) {
              try {
                await generateNewToken();
              } catch (refreshError) {
                _log(
                  'Token refresh failed but token is still valid',
                  error: refreshError.toString(),
                );
              }
            }
          }
          return true;
        }
      } catch (tokenInfoError) {
        _log(
          'Token info check failed, token is likely invalid',
          error: tokenInfoError.toString(),
        );
      }

      return false; // If we get here, all validation attempts failed
    } catch (e) {
      _log('Token validation completely failed', error: e.toString());
      return false;
    }
  }
}
