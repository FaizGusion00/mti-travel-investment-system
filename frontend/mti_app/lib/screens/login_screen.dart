import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final ApiService _apiService = ApiService();
  
  // Animation controller for logo pulsing
  late AnimationController _logoPulseController;
  late Animation<double> _logoPulseAnimation;

  // For syncing logo scale with modal drag
  double _modalExtent = 0.6; // initial extent
  static const double _minExtent = 0.55;
  static const double _maxExtent = 0.95;
  
  // Screen dimensions for responsive UI
  late double _screenHeight;
  late double _screenWidth;

  // For button microinteraction
  final ValueNotifier<bool> _isSignInPressed = ValueNotifier(false);
  final ValueNotifier<bool> _emailFocus = ValueNotifier(false);
  final ValueNotifier<bool> _passwordFocus = ValueNotifier(false);

  double get _logoSinePulse {
    // Smoother, natural sine-based pulse between 1.0 and 1.08
    final t = _logoPulseController.value * 2 * math.pi;
    return 1.04 + 0.04 * math.sin(t); // Range: 1.0–1.08, centered at 1.04
  }

  @override
  void initState() {
    super.initState();
    developer.log('LoginScreen initialized', name: 'MTI_Login');
    
    // Smoother, slower logo pulsing animation
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: false);
    _logoPulseAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_logoPulseController); // Not used, replaced by _logoSinePulse
    
    _loadSavedCredentials();
  }
  
  @override
  void dispose() {
    developer.log('LoginScreen disposed', name: 'MTI_Login');
    _emailController.dispose();
    _passwordController.dispose();
    _logoPulseController.dispose();
    _isSignInPressed.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
  
  // Load saved credentials if "Remember Me" was enabled
  Future<void> _loadSavedCredentials() async {
    developer.log('Loading saved credentials', name: 'MTI_Login');
    final storageService = StorageService();
    final isRememberMeEnabled = await storageService.isRememberMeEnabled();
    
    if (isRememberMeEnabled) {
      final credentials = await storageService.getSavedCredentials();
      developer.log('Found saved credentials', name: 'MTI_Login');
      setState(() {
        _emailController.text = credentials['email'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
        _rememberMe = true;
      });
    } else {
      developer.log('No saved credentials found', name: 'MTI_Login');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        
        developer.log('Attempting login for email: $email', name: 'MTI_Login');
        
        // Use the actual API service to login
        try {
          developer.log('Sending login request', name: 'MTI_Login');
          final response = await ApiService.login(email, password);
          developer.log('Login API response: ${response.toString()}', name: 'MTI_Login');
          
          if (response['success'] == true || response.containsKey('token') && response['token'] != null) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Log the token (truncated for security)
            final token = response['token'];
            if (token != null) {
              final truncatedToken = token.length > 15 
                  ? '${token.substring(0, 15)}...'
                  : token;
              developer.log('Login successful with token: $truncatedToken', name: 'MTI_Login');
            }
            
            // Save credentials if "Remember Me" is checked
            final storageService = StorageService();
            await storageService.saveUserCredentials(
              email: email,
              password: password,
              rememberMe: _rememberMe,
            );
            
            developer.log('Credentials saved: rememberMe=$_rememberMe', name: 'MTI_Login');
            
            // Save user data if available
            if (response.containsKey('user') && response['user'] != null) {
              await storageService.saveUserData(response['user']);
              developer.log('User data saved to storage', name: 'MTI_Login');
            }
            
            // Play success animation before navigating
            await _playSuccessAnimation();
            
            // Navigate to home screen on successful login
            Get.offAllNamed(AppRoutes.home);
          } else {
            // Show error message from API if available
            String errorMessage = 'Login failed';
            if (response.containsKey('message')) {
              errorMessage = response['message'];
            }
            
            developer.log('Login failed: $errorMessage', name: 'MTI_Login');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        } catch (apiError) {
          developer.log('API Error during login: $apiError', name: 'MTI_Login', error: apiError);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${apiError.toString()}'),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        developer.log('Login error: $e', name: 'MTI_Login', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _login,
              textColor: Colors.white,
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      developer.log('Login form validation failed', name: 'MTI_Login');
    }
  }
  
  // Play a success animation before navigating
  Future<void> _playSuccessAnimation() async {
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
      ),
      body: Stack(
                children: [
          // Animated background (no logo or welcome here)
          _buildAnimatedBackground(),
                  
          // Animated logo and Welcome text (single instance, responsive)
          Positioned(
            top: _screenHeight * 0.10,
            left: 0,
            right: 0,
                    child: Column(
                      children: [
                AnimatedBuilder(
                  animation: _logoPulseController,
                  builder: (context, child) {
                    final dragScale = 1.0 + ((_modalExtent - _minExtent) / (_maxExtent - _minExtent)) * 0.25;
                    final scale = _logoSinePulse * dragScale;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: _screenWidth * 0.24,
                    height: _screenWidth * 0.24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldColor.withOpacity(0.18),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                          child: Image.asset(
                            'assets/images/mti_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
                SizedBox(height: _screenHeight * 0.018),
                Shimmer.fromColors(
                  baseColor: AppTheme.goldColor,
                  highlightColor: AppTheme.tertiaryColor,
                  period: const Duration(seconds: 2),
                  child: Text(
                          "Welcome",
                          style: GoogleFonts.montserrat(
                      fontSize: (_screenWidth * 0.08).clamp(22, 32).toDouble(),
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                      color: AppTheme.goldColor,
                            shadows: [
                              Shadow(
                          color: AppTheme.goldColor.withOpacity(0.4),
                                offset: const Offset(0, 2),
                          blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: _screenHeight * 0.006),
                        Text(
                          "Sign in to continue",
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryTextColor,
                    fontSize: (_screenWidth * 0.042).clamp(12, 16).toDouble(),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
          ),

          // DraggableScrollableSheet for modal content
          DraggableScrollableSheet(
            initialChildSize: _modalExtent,
            minChildSize: _minExtent,
            maxChildSize: _maxExtent,
            snap: true,
            snapSizes: const [_minExtent, 0.8, _maxExtent],
            builder: (context, scrollController) {
              scrollController.addListener(() {
                final extent = (scrollController.position.viewportDimension + scrollController.position.pixels) / _screenHeight;
                if ((extent - _modalExtent).abs() > 0.01) {
                  setState(() {
                    _modalExtent = extent.clamp(_minExtent, _maxExtent);
                  });
                }
              });
              return _buildLoginContent(scrollController);
            },
          ),
        ],
      ),
    );
  }
  
  // Creates an animated background with particles and blur effects
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundColor,
            AppTheme.backgroundColor.withOpacity(0.8),
            AppTheme.surfaceColor.withOpacity(0.9),
          ],
        ),
      ),
    );
  }
  
  // Creates the main login content in a bottom sheet style
  Widget _buildLoginContent(ScrollController scrollController) {
    final modalPadding = EdgeInsets.symmetric(
      horizontal: (_screenWidth * 0.07).clamp(18, 32).toDouble(),
      vertical: (_screenHeight * 0.03).clamp(18, 32).toDouble(),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.10),
            blurRadius: 28,
            spreadRadius: 6,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.15),
          width: 1.4,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardColor.withOpacity(0.93),
            AppTheme.surfaceColor.withOpacity(0.88),
            Colors.white.withOpacity(0.04),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: modalPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: EdgeInsets.only(bottom: (_screenHeight * 0.018).clamp(8, 16).toDouble()),
                        decoration: BoxDecoration(
                          color: AppTheme.goldColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: AppTheme.goldColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Login",
                            style: GoogleFonts.montserrat(
                              color: AppTheme.goldColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 0.1,
                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  // Email field
                    ValueListenableBuilder<bool>(
                      valueListenable: _emailFocus,
                      builder: (context, hasFocus, child) {
                        return Focus(
                          onFocusChange: (focus) => _emailFocus.value = focus,
                          child: CustomTextField(
                    label: "Email",
                            hint: "Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                                return "Email required";
                      }
                      if (!GetUtils.isEmail(value)) {
                                return "Invalid email";
                      }
                      return null;
                    },
                            prefix: Icon(
                      Icons.email_outlined,
                              color: AppTheme.goldColor.withOpacity(0.85),
                            ),
                            style: GoogleFonts.inter(
                              color: AppTheme.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            enabled: true,
                            // Optionally: add a gold border if hasFocus is true
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  // Password field
                    ValueListenableBuilder<bool>(
                      valueListenable: _passwordFocus,
                      builder: (context, hasFocus, child) {
                        return Focus(
                          onFocusChange: (focus) => _passwordFocus.value = focus,
                          child: CustomTextField(
                    label: "Password",
                            hint: "Password",
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                                return "Password required";
                      }
                      return null;
                    },
                            prefix: Icon(
                      Icons.lock_outline,
                              color: AppTheme.goldColor.withOpacity(0.85),
                    ),
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.tertiaryTextColor,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                            style: GoogleFonts.inter(
                              color: AppTheme.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                                activeColor: AppTheme.goldColor,
                              checkColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                  color: AppTheme.goldColor.withOpacity(0.7),
                                  width: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Remember Me",
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.forgotPassword);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: AppTheme.goldColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 400.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                    const SizedBox(height: 18),
                    const SizedBox(height: 28),
                    // Login button - Redesigned with better animation and gradient
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSignInPressed,
                      builder: (context, pressed, child) {
                        return GestureDetector(
                          onTapDown: (_) => _isSignInPressed.value = true,
                          onTapUp: (_) => _isSignInPressed.value = false,
                          onTapCancel: () => _isSignInPressed.value = false,
                          child: AnimatedScale(
                            scale: pressed ? 0.97 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33FFD700),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CustomButton(
                    text: "Sign In",
                    onPressed: _login,
                    isLoading: _isLoading,
                    width: double.infinity,
                                height: 48,
                                borderRadius: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ).animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutQuad)
                      .shimmer(delay: 1000.ms, duration: 1800.ms, curve: Curves.easeInOut)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(
                        delay: Duration(seconds: 3),
                        duration: Duration(seconds: 2),
                        color: AppTheme.goldColor.withOpacity(0.3),
                      ),
                    const SizedBox(height: 18),
                    // Register link with improved styling
                    Center(
                      child: TextButton(
                        onPressed: () {
                          final Uri registrationUrl = Uri.parse(AppConstants.registrationUrl);
                          // Show a modern dialog for registration options
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                width: _screenWidth * 0.9,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                              ),
                                  ],
                                  border: Border.all(
                                    color: AppTheme.borderColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_add_outlined,
                                        color: AppTheme.goldColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Create Account",
                                      style: GoogleFonts.montserrat(
                                        color: AppTheme.primaryTextColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                ),
                              ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Registration is available on our website. Create your account to start investing.",
                                      textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppTheme.secondaryTextColor,
                                        fontSize: 14,
                                  ),
                                ),
                                    const SizedBox(height: 24),
                                    CustomButton(
                                      text: "Register on Website",
                                      icon: Icons.open_in_new,
                                  onPressed: () {
                                    Get.back();
                                    try {
                                      launchUrl(
                                        Uri.parse(AppConstants.registrationUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (e) {
                                      Get.snackbar(
                                        "Error",
                                            "Could not open website. Please visit "+AppConstants.registrationUrl+" manually.",
                                        backgroundColor: AppTheme.errorColor.withOpacity(0.7),
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                      type: ButtonType.primary,
                                      width: double.infinity,
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        "Cancel",
                                    style: TextStyle(
                                          color: AppTheme.tertiaryTextColor,
                                          fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms).scale(
                              begin: Offset(0.9, 0.9),
                              end: Offset(1, 1),
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.goldColor,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          "Create an account",
                          style: TextStyle(
                            color: AppTheme.goldColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "v0.0.3",
                      style: TextStyle(
                        color: AppTheme.tertiaryTextColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
