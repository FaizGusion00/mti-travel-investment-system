import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../widgets/custom_button.dart';
import '../utils/performance_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animationController;
  bool _useSimplifiedUI = false;

  @override
  void initState() {
    super.initState();
    // Check if we should use simplified animations
    _useSimplifiedUI = PerformanceUtils.shouldUseSimplifiedAnimations();

    // Use a shorter animation duration for better performance
    final animationDuration = _useSimplifiedUI ? 24000 : 12000;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: animationDuration),
    );

    // Only repeat animations if not using simplified UI
    if (!_useSimplifiedUI) {
      _animationController.repeat(reverse: false);
    } else {
      // For simplified UI, just run the animation once
      _animationController.forward();
    }

    // Listen for performance mode changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monitorPerformanceChanges();
    });
  }

  void _monitorPerformanceChanges() {
    // Check every few seconds if performance mode has changed
    Future.delayed(const Duration(seconds: 5), () {
      final newMode = PerformanceUtils.shouldUseSimplifiedAnimations();
      if (newMode != _useSimplifiedUI) {
        if (mounted) {
          setState(() {
            _useSimplifiedUI = newMode;
            // Adjust animation behavior based on new mode
            if (_useSimplifiedUI) {
              _animationController.stop();
            } else {
              _animationController.repeat(reverse: false);
            }
          });
        }
      }

      // Continue monitoring if widget is still mounted
      if (mounted) {
        _monitorPerformanceChanges();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Wrap the entire build method in error handling
    return PerformanceUtils.buildSafeWidget(
      builder: () => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom - 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader().animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 10),
                  _buildBalanceCard().animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.10, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 18),
                  _buildWalletsSection().animate().fadeIn(duration: 700.ms, delay: 200.ms).slideY(begin: 0.12, end: 0, duration: 700.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 100), // Space for bottom nav bar
                ],
              ),
            ),
          ),
        ),
      ),
      debugLabel: 'HomeScreen',
      fallback: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(
          child: Text(
            'Unable to load home screen. Please restart the app.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo to the left of welcome
              Image.asset(
                'assets/images/mti_logo.png',
                width: 38,
                height: 38,
              ).animate().fadeIn(duration: 500.ms).scale(begin: Offset(0.85, 0.85), end: Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Ahmad Ali",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.notification);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.settings);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundColor,
                    border: Border.all(
                      color: AppTheme.goldColor.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        children: [
          // Animated shine overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        begin: Alignment(-1.2 + 2.4 * _animationController.value, -1),
                        end: Alignment(1.2 - 2.4 * _animationController.value, 1),
                        colors: [
                          Colors.transparent,
                          AppTheme.goldColor.withOpacity(0.13),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Glassmorphism card with entrance animation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppTheme.goldColor.withOpacity(0.22),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.10),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
              backgroundBlendMode: BlendMode.overlay,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, color: AppTheme.goldColor, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "Total Balance",
                          style: GoogleFonts.inter(
                            color: AppTheme.goldColor.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          key: ValueKey(_isBalanceVisible),
                          color: Colors.white.withOpacity(0.8),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AnimatedCrossFade(
                  firstChild: Text(
                    "330,900 USDT",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: AppTheme.goldColor.withOpacity(0.12),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  secondChild: Text(
                    "••••••••••",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  crossFadeState: _isBalanceVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 6),
                    AnimatedCrossFade(
                      firstChild: Text(
                        "+3.28% | +\$408",
                        style: GoogleFonts.inter(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondChild: Text(
                        "••••••••••",
                        style: GoogleFonts.inter(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      crossFadeState: _isBalanceVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _buildLuxuryButton(
                        label: "Deposit",
                        icon: Icons.add,
                        gradient: AppTheme.depositGradient,
                        onTap: () => Get.toNamed(AppRoutes.deposit),
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLuxuryButton(
                        label: "Withdraw",
                        icon: Icons.arrow_downward,
                        gradient: AppTheme.withdrawGradient,
                        onTap: () => Get.toNamed(AppRoutes.withdraw),
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.10, end: 0, duration: 700.ms, curve: Curves.easeOutCubic).scale(begin: Offset(0.97, 0.97), end: Offset(1, 1), duration: 700.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildLuxuryButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.97, 0.97), end: Offset(1, 1), duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildWalletsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2),
            child: Text(
              "Your Accounts",
              style: TextStyle(
                color: AppTheme.goldColor.withOpacity(0.85),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildWalletCard(
            icon: Icons.card_giftcard,
            iconColor: AppTheme.goldColor,
            title: "Voucher Wallet",
            amount: "2,000",
            amountInUSDT: "USDT 2,000",
          ),
          const SizedBox(height: 12),
          _buildWalletCard(
            icon: Icons.account_balance_wallet,
            iconColor: AppTheme.goldColor,
            title: "Cash Wallet",
            amount: "230,460",
            amountInUSDT: "USDT 230,460",
          ),
          const SizedBox(height: 12),
          _buildWalletCard(
            icon: Icons.flight,
            iconColor: AppTheme.goldColor,
            title: "Travel Wallet",
            amount: "57,000",
            amountInUSDT: "USDT 57,000",
          ),
          const SizedBox(height: 12),
          _buildWalletCard(
            icon: Icons.currency_exchange,
            iconColor: AppTheme.goldColor,
            title: "XLM Wallet",
            amount: "181,000",
            amountInUSDT: "USDT 181,000",
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required String amountInUSDT,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.goldColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.95, 0.95), end: Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutCubic),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amountInUSDT,
                  style: TextStyle(
                    color: AppTheme.goldColor.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 120.ms),
            ],
          ),
        ],
      ),
    );
  }
}