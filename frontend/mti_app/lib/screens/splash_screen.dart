import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  String _version = 'v0.0.3';

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
    // Use different video source based on platform
    late VideoPlayerController controller;

    try {
      if (kIsWeb) {
        // For web, use network asset with the correct web path
        // The assets folder is at the root level in web builds
        try {
          controller = VideoPlayerController.network('assets/video/intro-video.mp4');
          developer.log('Using web video path: assets/video/intro-video.mp4', name: 'SplashScreen');
        } catch (e) {
          // If that fails, try with a leading slash
          developer.log('Error loading video, trying alternate path: $e', name: 'SplashScreen');
          controller = VideoPlayerController.network('/assets/video/intro-video.mp4');
        }
      } else {
        // For mobile, use the asset bundle
        controller = VideoPlayerController.asset('assets/video/intro-video.mp4');
        developer.log('Using mobile asset path', name: 'SplashScreen');
      }
    } catch (e) {
      // If any error occurs during controller creation, use a dummy controller
      // This ensures the app doesn't crash if the video file is missing or corrupted
      developer.log('Error creating video controller: $e', name: 'SplashScreen');
      controller = VideoPlayerController.asset('assets/video/intro-video.mp4');

      // Navigate to the next screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToNextScreen();
        }
      });
      setState(() {
        _isVideoInitialized = false;
      });
    }

    _videoPlayerController = controller;

    controller.initialize().then((_) {
      // Ensure the first frame is shown
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }

      // Play video with sound
      controller.setVolume(1.0);
      controller.play();

      developer.log('Video initialized and playing', name: 'SplashScreen');
      developer.log('Video duration: ${controller.value.duration.inSeconds}s', name: 'SplashScreen');

      // Navigate to next screen when video completes
      controller.addListener(() {
        final position = controller.value.position;
        final duration = controller.value.duration;

        // Check if we're at the end of the video
        if (position >= duration - const Duration(milliseconds: 300)) {
          developer.log('Video completed, navigating to next screen', name: 'SplashScreen');
          _navigateToNextScreen();
        }
      });

      // As a fallback, also navigate after a fixed time
      // This ensures navigation happens even if video listener fails
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          developer.log('Fallback timer triggered, navigating to next screen', name: 'SplashScreen');
          _navigateToNextScreen();
        }
      });
    }).catchError((error) {
      developer.log('Error initializing video: $error', name: 'SplashScreen');
      // If video fails to load, navigate after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Set state to avoid rendering issues
          setState(() {
            _isVideoInitialized = false;
          });
          _navigateToNextScreen();
        }
      });
    });
  }

  // Navigate to the appropriate screen based on auth status
  void _navigateToNextScreen() {
    // Only navigate if not already navigated
    if (Get.currentRoute == AppRoutes.splash && mounted) {
      // Safety check to prevent multiple navigations
      Future.microtask(() {
        try {
          // Ensure video is paused and released
          if (_videoPlayerController.value.isInitialized) {
            _videoPlayerController.pause();
          }

          // Double check auth status one more time before navigating to login
          StorageService().getAuthToken().then((token) {
            if (!mounted) return; // Safety check

            final bool hasToken = token != null && token.isNotEmpty;
            if (hasToken) {
              // If token exists, go to home
              Get.offAllNamed(AppRoutes.home);
            } else {
              // Otherwise go to login
              Get.offAllNamed(AppRoutes.login);
            }
          }).catchError((error) {
            if (!mounted) return; // Safety check

            // On error, default to login
            Get.offAllNamed(AppRoutes.login);
          });
        } catch (e) {
          developer.log('Error during navigation: $e', name: 'SplashScreen');
          // Failsafe - if anything goes wrong, go to login
          if (mounted) Get.offAllNamed(AppRoutes.login);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Logo as fallback if video fails (especially important for web)
                Center(
                  child: Image.asset(
                    'assets/images/mti_logo.png',
                    width: 180,
                    height: 180,
                  ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),
                ),
                // Video player takes the full screen
                if (_isVideoInitialized && _videoPlayerController.value.isInitialized)
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                      ),
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    ),
                  )
                else
                  const Center(
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
        },
      ),
    );
  }
}
