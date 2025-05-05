import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import screens
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
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
import '../screens/terms_conditions_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/contact_us_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
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
  static const String termsConditions = '/terms_conditions';
  static const String privacyPolicy = '/privacy_policy';
  static const String contactUs = '/contact_us';

  // Route map for GetX
  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(
      name: emailVerification,
      page: () => const EmailVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: network,
      page: () => const NetworkScreen(),
      transition: Transition.rightToLeft,
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
      page: () => const AccountsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: travel,
      page: () => const TravelScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: redeem,
      page: () => const RedeemScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: termsConditions,
      page: () => const TermsConditionsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: contactUs,
      page: () => const ContactUsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
