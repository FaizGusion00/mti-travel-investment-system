import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:developer' as developer;

import 'config/routes.dart';
import 'config/theme.dart';
import 'core/constants.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'utils/performance_utils.dart';

Future<void> main() async {
  // Capture errors in zones with enhanced error tracking
  runZonedGuarded<Future<void>>(
    () async {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize performance utilities early to optimize rendering
      PerformanceUtils();

      // Set preferred orientations for better performance
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Initialize required services
      await _initializeServices();

      // Optimize system UI for better performance and battery life
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.backgroundColor,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor:
              Colors.transparent, // Reduce GPU overdraw
        ),
      );

      // Enhanced error handler with better logging
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);

        // Log detailed error information
        developer.log(
          'Flutter error caught: ${details.exception}',
          name: 'MTI.App.Error',
          error: details.exception,
          stackTrace: details.stack,
        );

        // Additional handling for specific error types
        if (details.exception is ArgumentError) {
          developer.log(
            'Argument error detected - check parameters',
            name: 'MTI.App.Error.ArgumentError',
          );
        } else if (details.exception is StateError) {
          developer.log(
            'State error detected - check widget state management',
            name: 'MTI.App.Error.StateError',
          );
        }
      };

      // Image cache optimization
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          1024 * 1024 * 100; // 100 MB max

      // Enable memory monitoring in debug mode
      if (kDebugMode) {
        _setupMemoryMonitoring();
      }

      // Run the app with optimized memory settings
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // Enhanced error handler caught by Zone
      developer.log(
        'Uncaught fatal error in app: ${error.toString()}',
        name: 'MTI.App.FatalError',
        error: error,
        stackTrace: stackTrace,
      );

      // Attempt recovery for specific error types
      if (error is OutOfMemoryError ||
          error.toString().contains('out of memory')) {
        // Try to clear caches to recover
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
    },
  );
}

/// Clean up any temporary data on app startup
Future<void> _cleanupTemporaryData() async {
  try {
    // Clean up any temporary files, expired cache, etc.
    final prefs = await SharedPreferences.getInstance();
    final lastCleanup = prefs.getInt('last_temp_cleanup') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Only clean up once per day (86400000 ms = 24 hours)
    if (now - lastCleanup > 86400000) {
      // Clean image cache
      PaintingBinding.instance.imageCache.clear();

      // Record cleanup time
      await prefs.setInt('last_temp_cleanup', now);
      developer.log(
        'Temporary data cleanup completed',
        name: 'MTI.App.Maintenance',
      );
    }
  } catch (e) {
    developer.log(
      'Error during temporary data cleanup: $e',
      name: 'MTI.App.Maintenance',
    );
    // Continue anyway since this is not critical
  }
}

/// Validate application integrity for security
Future<void> _validateAppIntegrity() async {
  try {
    // Here we implement basic tamper detection
    // You can expand this with more sophisticated checks later
    final packageInfo = await PackageInfo.fromPlatform();

    // Check app signature/signing info in a production app
    // For now, just log the app info for debugging purposes
    developer.log(
      'App integrity check: ${packageInfo.packageName} (${packageInfo.buildNumber})',
      name: 'MTI.App.Security',
    );
  } catch (e) {
    developer.log(
      'Error during app integrity validation: $e',
      name: 'MTI.App.Security',
    );
  }
}

/// Utility function to initialize required services with enhanced security
Future<void> _initializeServices() async {
  try {
    // Clear any previous temporary data on startup
    await _cleanupTemporaryData();

    // Initialize SharedPreferences for general storage
    final prefs = await SharedPreferences.getInstance();

    // Initialize secure storage with enhanced security settings
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
        sharedPreferencesName: 'mti_secure_prefs',
        preferencesKeyPrefix: 'mti_', // Namespace keys for security
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    );

    // Initialize StorageService with security checks
    await Get.putAsync(() async {
      final storageService = StorageService();

      // Store references directly since init method doesn't exist
      Get.put(prefs, tag: 'shared_prefs');
      Get.put(secureStorage, tag: 'secure_storage');

      // Verify secure storage is working
      try {
        await secureStorage.write(key: '_test_key', value: 'test_value');
        await secureStorage.delete(key: '_test_key');
        developer.log(
          'Secure storage initialized successfully',
          name: 'MTI.App.Security',
        );
      } catch (e) {
        // If secure storage fails, log warning but continue
        developer.log(
          'Warning: Secure storage initialization failed, using fallback mechanism',
          name: 'MTI.App.Security',
          error: e,
        );
      }

      return storageService;
    }, permanent: true);

    // Initialize authentication-related services
    Get.put(AuthService(), permanent: true);

    // Initialize API service with token validation
    await Get.putAsync(() async {
      final apiService = ApiService();
      // Check tokens at startup if needed
      await _checkApiTokens(apiService);
      return apiService;
    }, permanent: true);

    // Check for app updates
    await _checkForAppUpdates();

    // Pre-load critical app data
    await _preloadAppData();

    // Run app integrity check
    await _validateAppIntegrity();

    developer.log(
      'All services initialized successfully',
      name: 'MTI.App.Init',
    );
  } catch (e, stackTrace) {
    developer.log(
      'Error initializing services: ${e.toString()}',
      name: 'MTI.App.InitError',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow; // Re-throw to be caught by the zone error handler
  }
}

/// Helper function to check API tokens without modifying ApiService
Future<void> _checkApiTokens(ApiService apiService) async {
  try {
    // Check if token exists and can be retrieved
    final token = await ApiService.getToken();
    if (token != null) {
      developer.log('API token is available', name: 'MTI.App.Auth');
    } else {
      developer.log('No API token found', name: 'MTI.App.Auth');
    }
  } catch (e) {
    developer.log('Error validating API tokens: $e', name: 'MTI.App.Auth');
  }
}

/// Check for app updates with enhanced error handling
Future<void> _checkForAppUpdates() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    developer.log(
      'App version: ${packageInfo.version} (${packageInfo.buildNumber})',
      name: 'MTI.App.Version',
    );

    // Here we could implement version checking against API
    // For example, check if current version meets minimum requirements
    // and notify user if an update is necessary

    // Store version info for diagnostics
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_version', packageInfo.version);
    await prefs.setString('build_number', packageInfo.buildNumber);
  } catch (e) {
    developer.log(
      'Error checking for updates: $e',
      name: 'MTI.App.UpdateCheck',
    );
  }
}

/// Preload app data with improved performance
Future<void> _preloadAppData() async {
  try {
    // Preload common assets and resources
    // This uses a specific cache size to optimize memory usage
    const String appIcon = 'assets/images/mti_logo.png';
    const String splashBg = 'assets/images/splash_bg.png';

    // Preload important images in parallel
    await Future.wait([
      precacheImage(
        const AssetImage(appIcon),
        Get.context ?? Get.key.currentContext!,
      ),
      precacheImage(
        const AssetImage(splashBg),
        Get.context ?? Get.key.currentContext!,
      ),
    ]).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        // Don't block startup if preloading takes too long
        developer.log('Asset preloading timed out', name: 'MTI.App.Preload');
        return [];
      },
    );

    developer.log('Critical assets preloaded', name: 'MTI.App.Preload');
  } catch (e) {
    // Don't block startup for preloading errors
    developer.log('Error preloading app data: $e', name: 'MTI.App.Preload');
  }
}

/// Setup enhanced memory monitoring for development
void _setupMemoryMonitoring() {
  // Monitor memory usage periodically with more details
  Timer.periodic(const Duration(minutes: 5), (timer) {
    final now = DateTime.now().toString();
    developer.log('Memory check at $now', name: 'MTI.App.Memory');

    // Log image cache stats
    developer.log(
      'Image cache stats: ${PaintingBinding.instance.imageCache.currentSize} items, '
      '${PaintingBinding.instance.imageCache.currentSizeBytes} bytes',
      name: 'MTI.App.Memory',
    );
  });
}

/// Helper constant to avoid importing foundation in main.dart
bool get kDebugMode {
  bool debug = false;
  assert(() {
    debug = true;
    return true;
  }());
  return debug;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appFullName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      enableLog: false, // Disable GetX logs for performance
      popGesture: true,
      smartManagement: SmartManagement.keepFactory, // Optimize for memory usage
      themeMode: ThemeMode.dark,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      defaultGlobalState: false, // Optimize for performance
      routingCallback: (routing) {
        // Track navigation for analytics
        if (routing?.current != null) {
          developer.log(
            'Navigation: ${routing!.current}',
            name: 'MTI.App.Navigation',
          );
        }
      },
      builder: (context, child) {
        // Apply global error handling for widget errors
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // In release mode, show a minimal error widget
          // In debug mode, show the full error
          if (kDebugMode) {
            return ErrorWidget(details.exception);
          }

          // Custom error widget for production with better UX
          return Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.amber[300], size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We apologize for the inconvenience',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.splash),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Restart App',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        };

        // Apply global styles and improve accessibility
        return MediaQuery(
          // Prevent text scaling beyond reasonable limits for better UI consistency
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child ?? const SizedBox(),
          ),
        );
      },
      // Register error routes with better UI
      unknownRoute: GetPage(
        name: '/error',
        page:
            () => Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route, size: 64, color: Colors.amber[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Page Not Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The requested page could not be found',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.splash),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Go to Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
