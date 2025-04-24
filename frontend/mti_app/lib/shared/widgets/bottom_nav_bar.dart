import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85, // Increased height to accommodate raised network button
      margin: const EdgeInsets.only(top: 3), // Add top margin to ensure proper positioning
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: AppTheme.secondaryBackgroundColor,
          selectedItemColor: AppTheme.goldColor,
          unselectedItemColor: AppTheme.tertiaryTextColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
          iconSize: 26, 
          selectedFontSize: 11, 
          unselectedFontSize: 10, 
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          enableFeedback: true,
          // Bottom padding is handled by container
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
            _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, "Accounts", 1),
            _buildNavItem(Icons.people_outline, Icons.people, "Network", 2),
            _buildNavItem(Icons.card_travel_outlined, Icons.card_travel, "Travel", 3),
            _buildNavItem(Icons.redeem_outlined, Icons.redeem, "Redeem", 4),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    // Special treatment for Network tab (index 2)
    if (index == 2) {
      return BottomNavigationBarItem(
        icon: Transform.translate(
          offset: const Offset(0, -05), // Move up by 15 pixels
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: currentIndex == index ? AppTheme.goldColor : const Color(0xFF3D99CC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (currentIndex == index ? AppTheme.goldColor : const Color(0xFF3D99CC)).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              currentIndex == index ? activeIcon : icon,
              size: 27,
              color: Colors.white,
            ),
          ),
        ),
        label: label,
        backgroundColor: Colors.transparent,
      );
    }
    
    // Regular tabs (non-Network)
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: currentIndex == index 
              ? AppTheme.goldColor.withOpacity(0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: currentIndex == index
              ? Border.all(color: AppTheme.goldColor.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: currentIndex == index 
              ? [
                  BoxShadow(
                    color: AppTheme.goldColor.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          currentIndex == index ? activeIcon : icon,
          size: currentIndex == index ? 26 : 24,
          color: currentIndex == index 
              ? AppTheme.goldColor 
              : AppTheme.tertiaryTextColor,
        ),
      ),
      label: label,
      backgroundColor: Colors.transparent,
    );
  }
}
