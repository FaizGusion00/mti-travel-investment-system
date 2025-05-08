import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import 'package:get/get.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Deposit",
          style: TextStyle(
            color: AppTheme.goldColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: AppTheme.goldColor.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackgroundColor,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppTheme.goldColor.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.goldColor,
                size: 50,
              ),
            ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 24),
            Text(
              "Coming Soon!",
              style: TextStyle(
                color: AppTheme.goldColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: AppTheme.goldColor.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutQuad,
                ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Our deposit functionality is currently under development. You'll soon be able to easily add funds to your account!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
