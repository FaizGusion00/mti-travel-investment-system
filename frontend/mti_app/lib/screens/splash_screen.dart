import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/constants.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  
  // Version information
  String _version = 'v0.0.2';

  @override
  void initState() {
    super.initState();
    
    // Get app version information
    _getVersionInfo();
    
    // Initialize video player
    _initVideoPlayer();
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
            // Video has completed, navigate to the next screen
            Get.offAllNamed(AppRoutes.login);
          }
        });

        // As a fallback, also navigate after the video duration + 500ms buffer
        Future.delayed(_videoPlayerController.value.duration + const Duration(milliseconds: 500), () {
          if (mounted) {
            Get.offAllNamed(AppRoutes.login);
          }
        });
      });
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
                // Skip the video and go to login screen
                _videoPlayerController.pause();
                Get.offAllNamed(AppRoutes.login);
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
