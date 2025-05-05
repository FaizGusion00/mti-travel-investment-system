import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:package_info_plus/package_info_plus.dart';
import '../core/constants.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _isCheckingAuth = false;
  
  // Version information
  String _version = 'v0.0.2';
  
  // Auth service
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    // Get app version information
    _getVersionInfo();
    
    // Check authentication status first
    _checkAuthStatus();
    
    // Initialize video player
    _initVideoPlayer();
  }
  
  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    developer.log('Checking authentication status', name: 'SplashScreen');
    setState(() => _isCheckingAuth = true);
    
    try {
      // Get token directly from storage without API validation
      final StorageService storageService = StorageService();
      final String? token = await storageService.getAuthToken();
      final bool hasToken = token != null && token.isNotEmpty;
      
      developer.log('Auth token exists: $hasToken', name: 'SplashScreen');
      
      if (hasToken) {
        // If we have a token, skip video and go directly to home screen
        // The actual token validation will happen in the home screen
        // This provides better UX by not making the user wait
        _videoPlayerController.pause();
        Get.offAllNamed(AppRoutes.home);
        return;
      }
      
      // No token found, continue with normal splash screen flow
      // Video will play and then redirect to login
      developer.log('No auth token found, continuing with splash video', name: 'SplashScreen');
      
    } catch (e) {
      developer.log('Error checking auth status: $e', name: 'SplashScreen');
      // Continue with normal flow, video will redirect to login
    } finally {
      if (mounted) setState(() => _isCheckingAuth = false);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  // Get version information from package info
  Future<void> _getVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = 'v${packageInfo.version}';
      });
    } catch (e) {
      // Use default version if package info fails
    }
  }

  void _initVideoPlayer() {
    _videoPlayerController = VideoPlayerController.asset('assets/video/intro-video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {
          _isVideoInitialized = true;
        });
        // Play video with sound
        _videoPlayerController.setVolume(1.0);
        _videoPlayerController.play();

        // Navigate to next screen when video completes
        _videoPlayerController.addListener(() {
          if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
            // Video has completed, navigate to the login screen if not already navigated
            _navigateToNextScreen();
          }
        });

        // As a fallback, also navigate after the video duration + 500ms buffer
        Future.delayed(_videoPlayerController.value.duration + const Duration(milliseconds: 500), () {
          if (mounted) {
            _navigateToNextScreen();
          }
        });
      });
  }

  // Navigate to the appropriate screen based on auth status
  void _navigateToNextScreen() {
    // Only navigate if not already navigated
    if (Get.currentRoute == AppRoutes.splash) {
      // Double check auth status one more time before navigating to login
      StorageService().getAuthToken().then((token) {
        final bool hasToken = token != null && token.isNotEmpty;
        if (hasToken) {
          // If token exists, go to home
          Get.offAllNamed(AppRoutes.home);
        } else {
          // Otherwise go to login
          Get.offAllNamed(AppRoutes.login);
        }
      }).catchError((error) {
        // On error, default to login
        Get.offAllNamed(AppRoutes.login);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player takes the full screen
          _isVideoInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoPlayerController.value.size.width,
                      height: _videoPlayerController.value.size.height,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.goldColor,
                  ),
                ),

          // Version info at the bottom
          Positioned(
            bottom: 16,
            right: 16,
            child: Text(
              _version,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),

          // Skip button
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: () {
                // Skip the video and go to next screen
                _videoPlayerController.pause();
                _navigateToNextScreen();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.goldColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
