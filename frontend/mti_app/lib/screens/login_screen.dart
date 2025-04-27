import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _captchaVerified = false;
  String _captchaToken = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Load saved credentials if "Remember Me" was enabled
  Future<void> _loadSavedCredentials() async {
    final storageService = StorageService();
    final isRememberMeEnabled = await storageService.isRememberMeEnabled();
    
    if (isRememberMeEnabled) {
      final credentials = await storageService.getSavedCredentials();
      setState(() {
        _emailController.text = credentials['email'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
        _rememberMe = true;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Check if captcha is verified
      if (!_captchaVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete the captcha verification'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        
        // Use the API service to login with captcha token
        final response = await _apiService.login(email, password, _captchaToken);
        
        if (response['success']) {
          // Save credentials if "Remember Me" is checked
          final storageService = StorageService();
          await storageService.saveUserCredentials(
            email: email,
            password: password,
            rememberMe: _rememberMe,
          );
          
          // Navigate to home screen on successful login
          Get.offAllNamed(AppRoutes.profile);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Login failed'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          color: Colors.transparent,
                          child: Image.asset(
                            'assets/images/mti_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Welcome",
                          style: GoogleFonts.montserrat(
                            color: AppTheme.goldColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: AppTheme.goldColor.withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Sign in to continue",
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Email field
                  CustomTextField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!GetUtils.isEmail(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                    prefix: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(
                    begin: 0.2,
                    end: 0,
                    delay: 200.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Password field
                  CustomTextField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                    prefix: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.tertiaryTextColor,
                    ),
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.tertiaryTextColor,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(
                    begin: 0.2,
                    end: 0,
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                  
                  const SizedBox(height: 24),
                  
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
                              activeColor: AppTheme.primaryColor,
                              checkColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                color: AppTheme.tertiaryTextColor,
                                width: 1.5,
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
                            color: AppTheme.primaryColor,
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
                  
                  const SizedBox(height: 24),
                  
                  // Captcha
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _captchaVerified
                            ? AppTheme.successColor.withOpacity(0.5)
                            : AppTheme.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Create a custom screen that properly displays and handles the captcha
                        final token = await Get.to(() => 
                          Scaffold(
                            appBar: AppBar(
                              title: const Text('Captcha Verification'),
                              backgroundColor: AppTheme.backgroundColor,
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Get.back(),
                              ),
                            ),
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Please complete the verification',
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  CloudflareTurnstile(
                                    siteKey: AppConstants.useCloudflareTestKey
                                        ? AppConstants.cloudflareTestSiteKey
                                        : AppConstants.cloudflareProdSiteKey,
                                    onTokenReceived: (token) {
                                      // Return the token to the previous screen
                                      Get.back(result: token);
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        );
                        
                        if (token != null) {
                          setState(() {
                            _captchaToken = token;
                            _captchaVerified = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _captchaVerified ? Icons.check_circle : Icons.security,
                              color: _captchaVerified ? AppTheme.successColor : AppTheme.goldColor,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _captchaVerified ? "Verified" : "Click to verify captcha",
                              style: TextStyle(
                                color: _captchaVerified ? AppTheme.successColor : AppTheme.secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 450.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login button
                  CustomButton(
                    text: "Sign In",
                    onPressed: _login,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 500.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final Uri registrationUrl = Uri.parse(AppConstants.registrationUrl);
                          // Open in web browser
                          // Use URL launcher package to open the web registration
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: AppTheme.cardColor,
                              title: const Text(
                                "Register on Website",
                                style: TextStyle(
                                  color: AppTheme.primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                "Registration is now available on our website. Please visit ${AppConstants.registrationUrl} to create an account.",
                                style: const TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: AppTheme.tertiaryTextColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    // Implement URL launching
                                    try {
                                      launchUrl(
                                        Uri.parse(AppConstants.registrationUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (e) {
                                      Get.snackbar(
                                        "Error",
                                        "Could not open website. Please visit ${AppConstants.registrationUrl} manually.",
                                        backgroundColor: AppTheme.errorColor.withOpacity(0.7),
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "Visit Website",
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 600.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
