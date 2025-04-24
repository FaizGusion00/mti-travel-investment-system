import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../shared/widgets/bottom_nav_bar.dart';
import '../config/routes.dart';
import 'home_screen.dart';
import 'accounts_screen.dart';
import 'network_screen.dart';
import 'travel_screen.dart';
import 'redeem_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  
  // List of screens for the bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const AccountsScreen(),
    const NetworkScreen(),
    const TravelScreen(),
    const RedeemScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handle page change from the PageView
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Handle tap on bottom navigation items
  void _onNavTap(int index) {
    // Don't animate if we're already on the selected tab
    if (_currentIndex == index) return;
    
    // Animate to the selected page with a smooth transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle back button press
      onWillPop: () async {
        if (_currentIndex != 0) {
          // If not on the home tab, go to home tab
          _onNavTap(0);
          return false;
        }
        return true; // Allow app to exit if on home tab
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swiping
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}
