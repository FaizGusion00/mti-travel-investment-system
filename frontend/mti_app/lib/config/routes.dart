import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import screens
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/network_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/travel_screen.dart';
import '../screens/redeem_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/deposit_screen.dart';
import '../screens/withdraw_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String network = '/network';
  static const String notification = '/notification';
  static const String settings = '/settings';
  static const String deposit = '/deposit';
  static const String withdraw = '/withdraw';
  static const String accounts = '/accounts';
  static const String travel = '/travel';
  static const String redeem = '/redeem';

  // Route map for GetX
  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: emailVerification,
      page: () => const EmailVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const MainNavigationScreen(initialIndex: 0),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: network,
      page: () => const MainNavigationScreen(initialIndex: 2),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notification,
      page: () => const NotificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: deposit,
      page: () => const DepositScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: withdraw,
      page: () => const WithdrawScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: accounts,
      page: () => const MainNavigationScreen(initialIndex: 1),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: travel,
      page: () => const MainNavigationScreen(initialIndex: 3),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: redeem,
      page: () => const MainNavigationScreen(initialIndex: 4),
      transition: Transition.fadeIn,
    ),
  ];
  
  // Route map for MaterialApp
  static final Map<String, WidgetBuilder> materialRoutes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    emailVerification: (context) => const EmailVerificationScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    network: (context) => const NetworkScreen(),
    notification: (context) => const NotificationScreen(),
    settings: (context) => const SettingsScreen(),
    accounts: (context) => const AccountsScreen(),
    travel: (context) => const TravelScreen(),
    redeem: (context) => const RedeemScreen(),
  };
}
