import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:package_info_plus/package_info_plus.dart';
import '../core/constants.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Version information
  String _version = 'v0.0.2';
  
  // For the shimmering effect
  final List<Color> _shimmerColors = [
    Colors.transparent,
    Colors.transparent,
    AppTheme.goldColor.withOpacity(0.05),
    AppTheme.goldColor.withOpacity(0.1),
    Colors.white.withOpacity(0.2),
    AppTheme.goldColor.withOpacity(0.1),
    AppTheme.goldColor.withOpacity(0.05),
    Colors.transparent,
    Colors.transparent,
  ];

  @override
  void initState() {
    super.initState();
    
    // Get app version information
    _getVersionInfo();
    
    // Main animation controller for the logo and text
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Pulse animation for the background glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    // Rotation animation for the shimmer effect
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    _animationController.forward();
    
    // Navigate to next screen after animation completes
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // Get version information from package info
  Future<void> _getVersionInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = 'v${packageInfo.version}';
      });
    } catch (e) {
      // Use default version if package info fails
      setState(() {
        _version = 'v0.0.2';
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Simulate loading time and check authentication state
      await Future.delayed(const Duration(seconds: 4));
      
      // Check if user is logged in
      // This will be implemented with actual auth logic later
      const bool isLoggedIn = false;
      
      if (isLoggedIn) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e, stack) {
      debugPrint('Error in splash navigation: $e');
      debugPrint('Stack trace: $stack');
      // Fallback to login screen if there's an error
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.0,
                colors: [
                  const Color(0xFF0A0A0A),
                  Colors.black,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          
          // Animated particles in the background (subtle gold particles)
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Lottie.asset(
                'assets/animations/gold_particles.json',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated logo with glow effect
                Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing background glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 200 + (10 * _pulseController.value),
                        height: 200 + (10 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.goldColor.withOpacity(0.1 + 0.05 * _pulseController.value),
                              Colors.transparent,
                            ],
                            stops: const [0.2, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Rotating shimmer effect
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: _shimmerColors,
                            stops: const [0.0, 0.3, 0.33, 0.4, 0.5, 0.6, 0.67, 0.7, 1.0],
                            transform: GradientRotation(
                              2 * math.pi * _rotationController.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Actual logo with scale and fade animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.goldColor.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/mti_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // App name with shimmer effect
              ShimmerText(
                text: AppConstants.appFullName.toUpperCase(),
                baseColor: Colors.white,
                highlightColor: AppTheme.goldColor,
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                ),
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: 500.ms),
              
              const SizedBox(height: 8),
              
              // Tagline with gold color
              Text(
                "TRAVEL • INVEST • EARN",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.goldColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3.0,
                ),
              )
              .animate()
              .fadeIn(delay: 600.ms, duration: 800.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 600.ms,
                duration: 800.ms,
                curve: Curves.easeOutQuad,
              ),
              
              const SizedBox(height: 80),
              
              // Luxury loading animation
              SizedBox(
                height: 60,
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppTheme.goldColor,
                  size: 40,
                ),
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: 500.ms),
              
              // Version number at the bottom
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _version,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 500.ms),
            ],
          )),
        ],
      ),
    );
  }
}

// Custom shimmer text widget for luxury effect
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerText({
    Key? key,
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_animation.value * 2 * math.pi),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: widget.style,
          ),
        );
      },
    );
  }
}
