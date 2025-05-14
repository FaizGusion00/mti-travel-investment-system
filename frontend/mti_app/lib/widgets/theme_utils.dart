import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import 'galaxy_background.dart';

/// Theme utilities for consistent application of the galaxy theme
class ThemeUtils {
  /// Wrap the given page with the galaxy background
  static Widget withGalaxyBackground(
    Widget child, {
    double starDensity = 1.0,
    double nebulaOpacity = 0.15,
    bool showShootingStars = true,
  }) {
    return GalaxyBackground(
      starDensity: starDensity,
      nebulaOpacity: nebulaOpacity,
      showShootingStars: showShootingStars,
      child: child,
    );
  }
  
  /// Set the status bar to transparent with light icons
  static void setTransparentStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }
  
  /// Show a custom toast with the app's theme
  static void showToast(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Info',
      message,
      backgroundColor: isError 
        ? AppTheme.errorColor.withOpacity(0.9) 
        : AppTheme.primaryColor.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
  
  /// Apply the theme's gradient to a container
  static BoxDecoration getGradientDecoration({bool isCard = false}) {
    return BoxDecoration(
      gradient: isCard 
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.93),
              AppTheme.surfaceColor.withOpacity(0.88),
            ],
          )
        : AppTheme.luxuryGalaxyGradient(opacity: 0.9),
      borderRadius: BorderRadius.circular(isCard ? 16 : 0),
      border: isCard ? Border.all(
        color: AppTheme.goldColor.withOpacity(0.15),
        width: 1.4,
      ) : null,
      boxShadow: isCard ? [
        BoxShadow(
          color: AppTheme.goldColor.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ] : null,
    );
  }
} 