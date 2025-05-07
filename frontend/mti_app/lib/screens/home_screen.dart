import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../widgets/custom_button.dart';
import '../utils/performance_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as developer;
import '../utils/number_formatter.dart';
import '../services/api_service.dart';
import 'swap_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../core/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animationController;
  late AnimationController _balanceGradientController;
  late AnimationController _typingAnimationController;
  bool _useSimplifiedUI = false;

  // For typing animation
  double _cashWalletDisplay = 0;
  double _voucherWalletDisplay = 0;
  double _travelWalletDisplay = 0;
  double _xlmWalletDisplay = 0;

  // User data
  String _fullName = "";
  bool _isTrader = false;
  String _refCode = ""; // Store user's reference code

  // Wallet balances
  double _cashWallet = 0.0;
  double _voucherWallet = 0.0;
  double _travelWallet = 0.0;
  double _xlmWallet = 0.0;
  double _totalBalance = 0.0;
  bool _isLoading = true;

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

    // Balance gradient controller - will be used for a more natural animation
    _balanceGradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Typing animation controller for wallet amounts
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Only repeat animations if not using simplified UI
    if (!_useSimplifiedUI) {
      _animationController.repeat(reverse: false);
      _balanceGradientController.repeat(reverse: true);
    } else {
      // For simplified UI, just run the animation once
      _animationController.forward();
      _balanceGradientController.forward();
    }

    // Fetch user profile and wallet data
    _fetchUserData();

    // Listen for wallet refresh events from other screens (like swap_screen)
    // This will auto-refresh the wallet balances when a transfer occurs
    developer.log(
      'Setting up WalletEvents listener in HomeScreen',
      name: 'MTI_Home',
    );

    // Use ever from GetX to listen to the observable
    ever(WalletEvents.refreshWallets, (_) {
      developer.log(
        'Wallet refresh event received in HomeScreen',
        name: 'MTI_Home',
      );
      _fetchUserData(); // Refresh wallet data when event triggered
    });

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

  // Fetch user profile and wallet data
  Future<void> _fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get user profile
      final profileResponse = await ApiService.getProfile();
      if (profileResponse['success'] == true &&
          profileResponse['user'] != null) {
        final userData = profileResponse['user'];

        // Use the full name as provided by the API
        final fullName = userData['full_name']?.toString() ?? 'User';

        // Get reference code
        final refCode = userData['affiliate_code']?.toString() ?? '';

        setState(() {
          _fullName = fullName;
          _isTrader =
              userData['is_trader'] == 1 || userData['is_trader'] == true;
          _refCode = refCode;
        });

        developer.log('User ref code: $_refCode', name: 'MTI_Home');

        developer.log('User is trader: $_isTrader', name: 'MTI_Home');
      }

      // Get wallet balances
      final walletResponse = await ApiService.getWalletBalances();
      if (walletResponse['status'] == 'success' &&
          walletResponse['data'] != null) {
        final walletData = walletResponse['data'];

        // Parse wallet balances
        final cashWallet =
            double.tryParse(walletData['cash_wallet'].toString()) ?? 0.0;
        final voucherWallet =
            double.tryParse(walletData['voucher_wallet'].toString()) ?? 0.0;
        final travelWallet =
            double.tryParse(walletData['travel_wallet'].toString()) ?? 0.0;
        final xlmWallet =
            double.tryParse(walletData['xlm_wallet'].toString()) ?? 0.0;

        // Calculate total balance (excluding voucher wallet)
        final totalBalance = cashWallet + travelWallet + xlmWallet;

        setState(() {
          _cashWallet = cashWallet;
          _voucherWallet = voucherWallet;
          _travelWallet = travelWallet;
          _xlmWallet = xlmWallet;
          _totalBalance = totalBalance;
          _isLoading = false;

          // Initialize display values for typing animation
          _cashWalletDisplay = 0;
          _voucherWalletDisplay = 0;
          _travelWalletDisplay = 0;
          _xlmWalletDisplay = 0;
        });

        // Start typing animation for wallet values
        _typingAnimationController.reset();
        _typingAnimationController.forward();

        // Add listener to update the display values during animation
        _typingAnimationController.addListener(() {
          if (mounted) {
            setState(() {
              _cashWalletDisplay =
                  _cashWallet * _typingAnimationController.value;
              _voucherWalletDisplay =
                  _voucherWallet * _typingAnimationController.value;
              _travelWalletDisplay =
                  _travelWallet * _typingAnimationController.value;
              _xlmWalletDisplay = _xlmWallet * _typingAnimationController.value;
            });
          }
        });

        developer.log(
          'Wallet balances fetched successfully!',
          name: 'MTI_Home',
        );
      } else {
        developer.log('Failed to fetch wallet balances', name: 'MTI_Home');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _balanceGradientController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  // Method to launch MTI web registration page with current user's reference code
  Future<void> _launchMTIWebRegistration() async {
    try {
      // Construct the URL with reference code parameter for Next.js routing
      final urlString =
          '${AppConstants.registrationUrl}/register?ref=${_refCode}';

      // Log the URL being launched
      developer.log(
        'Launching MTI web registration with ref code: $_refCode',
        name: 'MTI_Home',
      );
      developer.log('URL: $urlString', name: 'MTI_Home');

      // Launch the URL using launchUrlString for simpler implementation
      if (!await launchUrlString(
        urlString,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      developer.log('Error launching registration URL: $e', name: 'MTI_Home');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open registration page. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Wrap the entire build method in error handling
    return PerformanceUtils.buildSafeWidget(
      builder:
          () => Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: RefreshIndicator(
              onRefresh: () async {
                await _fetchUserData();
              },
              color: AppTheme.goldColor,
              backgroundColor: AppTheme.secondaryBackgroundColor,
              child: SafeArea(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height -
                                  MediaQuery.of(context).padding.top -
                                  MediaQuery.of(context).padding.bottom -
                                  80,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader()
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      duration: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                const SizedBox(height: 10),
                                _buildBalanceCard()
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 100.ms)
                                    .slideY(
                                      begin: 0.10,
                                      end: 0,
                                      duration: 600.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                const SizedBox(height: 18),
                                _buildWalletsSection()
                                    .animate()
                                    .fadeIn(duration: 700.ms, delay: 200.ms)
                                    .slideY(
                                      begin: 0.12,
                                      end: 0,
                                      duration: 700.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                const SizedBox(
                                  height: 100,
                                ), // Space for bottom nav bar
                              ],
                            ),
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
              Image.asset('assets/images/mti_logo.png', width: 38, height: 38)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: Offset(0.85, 0.85),
                    end: Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
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
                    _fullName.isEmpty ? "User" : _fullName,
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
                    child: Icon(Icons.settings_outlined, color: Colors.white),
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
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment(
                          -1.2 + 2.4 * _animationController.value,
                          -1,
                        ),
                        end: Alignment(
                          1.2 - 2.4 * _animationController.value,
                          1,
                        ),
                        colors: [
                          Colors.transparent,
                          AppTheme.goldColor.withOpacity(0.15),
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
          // Modern card with luxury animated background
          Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.goldColor.withOpacity(0.22),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment(
                      -0.5 - (_animationController.value * 0.5),
                      -0.5,
                    ),
                    end: Alignment(
                      0.5 + (_animationController.value * 0.5),
                      0.5,
                    ),
                    colors: const [
                      Color(0xFF111111), // Deep black
                      Color(0xFF1E1E1E), // Rich black
                      Color(0xFF242424), // Dark charcoal
                      Color(0xFF1A1A1A), // Medium black
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppTheme.goldColor.withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1.0 + (2.0 * _animationController.value),
                      -0.5 + (_animationController.value),
                    ),
                    end: Alignment(
                      0.0 + (1.0 * _animationController.value),
                      0.5 + (_animationController.value),
                    ),
                    colors: [
                      Colors.transparent,
                      AppTheme.goldColor.withOpacity(0.03),
                      AppTheme.goldColor.withOpacity(0.07),
                      AppTheme.goldColor.withOpacity(0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.goldColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppTheme.goldColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Total Balance",
                              style: GoogleFonts.inter(
                                color: AppTheme.goldColor,
                                fontSize: 14,
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
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                _isBalanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                key: ValueKey(_isBalanceVisible),
                                color: Colors.white.withOpacity(0.8),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedCrossFade(
                      firstChild: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              const Color(0xFFFFD700), // Gold
                              const Color(0xFFFFF5E0), // Light gold
                              const Color(0xFFD4AF37), // Metallic gold
                              const Color(0xFFFFD700), // Gold again
                            ],
                            stops: [
                              0.0 + (_balanceGradientController.value * 0.5),
                              0.3 + (_balanceGradientController.value * 0.2),
                              0.6 + (_balanceGradientController.value * 0.3),
                              0.9 + (_balanceGradientController.value * 0.1),
                            ],
                            begin: Alignment(
                              -1.0 + _balanceGradientController.value * 2,
                              0,
                            ),
                            end: Alignment(
                              1.0 + _balanceGradientController.value,
                              0,
                            ),
                          ).createShader(bounds);
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "\$",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: NumberFormatter.formatCurrency(
                                  _totalBalance,
                                ),
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.goldColor.withOpacity(
                                        0.25,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 2),
                                    ),
                                    Shadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      secondChild: Text(
                        "••••••••••",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      crossFadeState:
                          _isBalanceVisible
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 10),
                    // Removed the green increase number as per requirements
                    const SizedBox(height: 20),
                    // Action buttons with modern design
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModernActionButton(
                          label: "Register",
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFF2196F3),
                          onTap: () async {
                            developer.log(
                              'Register button tapped',
                              name: 'MTI_Home',
                            );
                            await _launchMTIWebRegistration();
                          },
                        ),
                        if (_isTrader)
                          _buildModernActionButton(
                            label: "Swap",
                            icon: Icons.swap_horiz,
                            color: const Color(0xFFFFA000),
                            onTap: () {
                              // Navigate to swap page
                              Get.to(() => const SwapScreen());
                            },
                          ),
                        _buildModernActionButton(
                          label: "Deposit",
                          icon: Icons.arrow_downward,
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            // Navigate to deposit page
                            Get.toNamed(AppRoutes.deposit);
                          },
                        ),
                        _buildModernActionButton(
                          label: "Withdraw",
                          icon: Icons.arrow_upward,
                          color: const Color(0xFFF44336),
                          onTap: () {
                            // Navigate to withdraw page
                            Get.toNamed(AppRoutes.withdraw);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 700.ms)
              .slideY(
                begin: 0.10,
                end: 0,
                duration: 700.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: Offset(0.97, 0.97),
                end: Offset(1, 1),
                duration: 700.ms,
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
    );
  }

  // Circular button widget that matches the reference image with gradient support
  // New modern action button design
  Widget _buildModernActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: color, size: 22)),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Keep the original method for backward compatibility
  Widget _buildCircularButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: Colors.white, size: 24)),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.97, 0.97),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF4CAF50), // Green for cash
            title: "Cash Wallet",
            amount: "\$${NumberFormatter.formatCurrency(_cashWallet)}",
            amountInUSDT: "USDT ${NumberFormatter.formatCurrency(_cashWallet)}",
          ),
          const SizedBox(height: 12),
          _buildWalletCard(
            icon: Icons.card_giftcard,
            iconColor: const Color(0xFFE91E63), // Pink for gift/voucher
            title: "Voucher Wallet",
            amount: "${NumberFormatter.formatWithCommas(_voucherWallet)}",
            amountInUSDT:
                "${NumberFormatter.formatWithCommas(_voucherWallet.toInt())} Points",
          ),
          const SizedBox(height: 12),
          _buildWalletCard(
            icon: Icons.flight,
            iconColor: const Color(0xFF2196F3), // Blue for travel
            title: "Travel Wallet",
            amount: "\$${NumberFormatter.formatCurrency(_travelWallet)}",
            amountInUSDT:
                "USDT ${NumberFormatter.formatCurrency(_travelWallet)}",
          ),
          const SizedBox(height: 12),
          _buildWalletCard(
            icon: Icons.currency_exchange,
            iconColor: const Color(0xFFFF9800), // Orange for XLM
            title: "XLM Wallet",
            amount: "\$${NumberFormatter.formatCurrency(_xlmWallet)}",
            amountInUSDT: "USDT ${NumberFormatter.formatCurrency(_xlmWallet)}",
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
    // Determine which display value to use based on wallet type
    double displayAmount = 0;
    if (title == "Cash Wallet") {
      displayAmount = _cashWalletDisplay;
    } else if (title == "Voucher Wallet") {
      displayAmount = _voucherWalletDisplay;
    } else if (title == "Travel Wallet") {
      displayAmount = _travelWalletDisplay;
    } else if (title == "XLM Wallet") {
      displayAmount = _xlmWalletDisplay;
    }

    // Format the display amounts
    String formattedAmount = amount;
    String formattedUSDT = amountInUSDT;

    if (title == "Cash Wallet") {
      formattedAmount = "\$${NumberFormatter.formatCurrency(displayAmount)}";
      formattedUSDT = "USDT ${NumberFormatter.formatCurrency(displayAmount)}";
    } else if (title == "Voucher Wallet") {
      formattedAmount = "${NumberFormatter.formatWithCommas(displayAmount)}";
      formattedUSDT =
          "${NumberFormatter.formatWithCommas(displayAmount.toInt())} Points";
    } else if (title == "Travel Wallet" || title == "XLM Wallet") {
      formattedAmount = "${NumberFormatter.formatCurrency(displayAmount)}";
      formattedUSDT = "USDT ${NumberFormatter.formatCurrency(displayAmount)}";
    }
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
                child: Icon(icon, color: iconColor, size: 22),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: Offset(0.95, 0.95),
                end: Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
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
                  formattedUSDT,
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
                formattedAmount,
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
