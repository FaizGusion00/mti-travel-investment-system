import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'core/constants.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'utils/performance_utils.dart';

Future<void> main() async {
  // Capture errors in zones
  runZonedGuarded<Future<void>>(() async {
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

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Enhanced error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      developer.log(
        'Flutter error caught by FlutterError.onError',
        name: 'MTI.App.Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    // Enable memory monitoring in debug mode
    if (kDebugMode) {
      _setupMemoryMonitoring();
    }

    // Run the app
    runApp(const MyApp());

  }, (error, stackTrace) {
    // Handle errors caught by Zone
    developer.log(
      'Uncaught error in app',
      name: 'MTI.App.FatalError',
      error: error,
      stackTrace: stackTrace,
    );
  });
}

/// Utility function to initialize required services
Future<void> _initializeServices() async {
  try {
    // Initialize SharedPreferences for general storage
    final prefs = await SharedPreferences.getInstance();

    // Initialize secure storage with enhanced security
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
        sharedPreferencesName: 'mti_secure_prefs',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    );

    // Initialize StorageService as a dependency
    await Get.putAsync(() async {
      final storageService = StorageService();
      // Store references directly since init method doesn't exist
      Get.put(prefs, tag: 'shared_prefs');
      Get.put(secureStorage, tag: 'secure_storage');
      return storageService;
    }, permanent: true);

    // Initialize ApiService as a dependency
    await Get.putAsync(() async {
      final apiService = ApiService();
      // ApiService doesn't have an init method, so we just return the instance
      return apiService;
    }, permanent: true);

    // Check for app updates (could be expanded to implement actual update logic)
    await _checkForAppUpdates();

    // Pre-load critical app data
    await _preloadAppData();

    developer.log('All services initialized successfully', name: 'MTI.App.Init');
  } catch (e, stackTrace) {
    developer.log(
      'Error initializing services',
      name: 'MTI.App.InitError',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow; // Re-throw to be caught by the zone error handler
  }
}

/// Check for app updates
Future<void> _checkForAppUpdates() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    developer.log(
      'App version: ${packageInfo.version} (${packageInfo.buildNumber})',
      name: 'MTI.App.Version',
    );
    // Here you could implement version checking against your API
  } catch (e) {
    developer.log('Error checking for updates: $e', name: 'MTI.App.UpdateCheck');
  }
}

/// Preload app data that might be needed immediately
Future<void> _preloadAppData() async {
  // You could preload user preferences, cached data, etc.
  // This runs during startup but doesn't block the UI
}

/// Setup memory monitoring for development
void _setupMemoryMonitoring() {
  // Monitor memory usage periodically
  Timer.periodic(const Duration(minutes: 5), (timer) {
    developer.log(
      'Memory check',
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
      enableLog: false,
      popGesture: true,
      smartManagement: SmartManagement.keepFactory,
      themeMode: ThemeMode.dark,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      builder: (context, child) {
        // Apply global error handling for widget errors
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // Log the error for debugging
          developer.log(
            'Widget error: ${details.exception}',
            name: 'MTI.App.WidgetError',
            error: details.exception,
            stackTrace: details.stack,
          );

          // In release mode, show a minimal error widget
          // In debug mode, show the full error
          if (kDebugMode) {
            return ErrorWidget(details.exception);
          }

          // Custom error widget for production
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              minWidth: 100,
              minHeight: 100,
            ),
            child: const Text(
              'Sorry, something went wrong.',
              style: TextStyle(color: Colors.white),
            ),
          );
        };

        // Add directionality and any other global styles
        return MediaQuery(
          // Prevent text scaling beyond reasonable limits for better UI consistency
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear((
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2))
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child != null ?
            SafeArea(
              // Add SafeArea to ensure proper layout constraints
              bottom: false,
              child: child,
            ) :
            const SizedBox(width: 100, height: 100),
          ),
        );
      },
      // Register error routes
      unknownRoute: GetPage(
        name: '/error',
        page: () => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      ),
    );
  }
}
