import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:developer' as developer;

/// Utility class for managing performance optimizations
class PerformanceUtils {
  // Static memory cache
  static bool? _cachedSimplifiedMode;
  static bool? _isEmulator = true; // Default to true to be safe
  
  // Initialize system check - call this in the main() function if possible
  static void init() {
    _checkIsEmulator();
    developer.log('PerformanceUtils initialized, simplified mode: ${shouldUseSimplifiedAnimations()}', name: 'Performance');
  }
  
  /// Checks if the device is likely an emulator
  static Future<bool> _checkIsEmulator() async {
    if (_isEmulator != null) {
      return _isEmulator!;
    }
    
    bool emulatorDetected = false;
    
    try {
      if (Platform.isAndroid) {
        // Most Android emulators include these in their model/brand
        final String androidModel = Platform.operatingSystemVersion.toLowerCase();
        emulatorDetected = androidModel.contains('sdk') || 
                          androidModel.contains('emulator') ||
                          androidModel.contains('android_studio') ||
                          androidModel.contains('genymotion');
      } else if (Platform.isIOS) {
        // iOS simulator detection
        emulatorDetected = !kIsWeb && Platform.isIOS && 
                         !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
      }
    } catch (e) {
      developer.log('Error detecting emulator: $e', name: 'Performance');
    }
    
    _isEmulator = emulatorDetected;
    developer.log('Emulator detected: $emulatorDetected', name: 'Performance');
    return emulatorDetected;
  }

  /// Checks if the application should use simplified animations
  /// This reduces animations on low-end devices to improve performance
  static bool shouldUseSimplifiedAnimations() {
    // Return cached value if available
    if (_cachedSimplifiedMode != null) {
      return _cachedSimplifiedMode!;
    }

    // Check device performance metrics
    bool shouldSimplify = true; // Default to true to be safe with emulators
    
    // Always simplify on emulators to avoid OpenGL issues
    if (_isEmulator == true) {
      shouldSimplify = true;
      developer.log('Using simplified animations for emulator', name: 'Performance');
    } 
    // Only use complex animations in release builds on physical devices
    else if (!kDebugMode && !_isEmulator!) {
      // Allow complex animations on physical devices in release mode
      shouldSimplify = false;
      developer.log('Using full animations for physical device', name: 'Performance');
    } else {
      // Use simplified mode for all debug builds
      shouldSimplify = true;
    }
    
    // Cache the result
    _cachedSimplifiedMode = shouldSimplify;
    return shouldSimplify;
  }
  
  /// Creates a widget with error handling
  /// If an error occurs during build, shows the fallback widget
  static Widget buildSafeWidget({
    required Widget Function() builder,
    required Widget fallback,
    String? debugLabel,
  }) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error building $debugLabel: $e');
      debugPrint(stackTrace.toString());
      return fallback;
    }
  }
  
  /// Returns an optimized gradient based on performance mode
  /// For low-end devices, returns a simpler gradient
  /// Accepts full gradient and simplified gradient options for more control
  static Gradient optimizedGradient(
    List<Color> colors, {
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    Gradient? fullGradient,
    Gradient? simplifiedGradient,
  }) {
    final simplified = shouldUseSimplifiedAnimations();
    
    if (simplified) {
      // Use provided simplified gradient if available
      if (simplifiedGradient != null) {
        return simplifiedGradient;
      }
      
      // Otherwise create a simple linear gradient with minimal colors
      return LinearGradient(
        colors: colors.length > 2 ? [colors.first, colors.last] : colors,
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
      );
    } else {
      // Use provided full gradient if available
      if (fullGradient != null) {
        return fullGradient;
      }
      
      // Otherwise create a normal linear gradient
      return LinearGradient(
        colors: colors,
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
      );
    }
  }
}
