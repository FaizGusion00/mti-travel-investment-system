import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final EmailOTP emailOTP = EmailOTP();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpSent = false;
  bool _otpVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _sendOTP() async {
    if (!_otpSent && _formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      
      setState(() {
        _isLoading = true;
      });

      try {
        // Configure email OTP
        emailOTP.setConfig(
          appEmail: AppConstants.emailFromAddress.isNotEmpty 
              ? AppConstants.emailFromAddress 
              : "mti.support@example.com",
          appName: AppConstants.appFullName,
          userEmail: email,
          otpLength: AppConstants.otpLength,
          otpType: OTPType.digitsOnly,
        );
        
        // Send OTP
        await emailOTP.sendOTP();
        
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification code: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _verifyOTP() async {
    // Combine all OTP digits
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    // Validate OTP length
    if (otp.length != AppConstants.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter all ${AppConstants.otpLength} digits'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Verify OTP
      bool isVerified = await emailOTP.verifyOTP(otp: otp);
      
      if (isVerified) {
        setState(() {
          _otpVerified = true;
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful. Please set a new password.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid verification code. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call to reset password
        await Future.delayed(const Duration(seconds: 2));
        
        // Show success dialog
        Get.dialog(
          AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Password Reset Successful",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Your password has been reset successfully. Please login with your new password.",
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.offAllNamed(AppRoutes.login); // Go to login screen
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
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

  // Helper method to build OTP input field
  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.goldColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.goldColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.cardColor,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
            // Move to next field
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            // Move to previous field
            FocusScope.of(context).previousFocus();
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
  
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
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Forgot password illustration
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      _otpVerified ? Icons.lock_reset : (_otpSent ? Icons.sms_outlined : Icons.lock_reset_outlined),
                      color: AppTheme.goldColor,
                      size: 60,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title and description - changes based on current step
                  Text(
                    _otpVerified ? "Set New Password" : (_otpSent ? "Verify Your Email" : "Reset Your Password"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _otpVerified 
                      ? "Please enter your new password"
                      : (_otpSent 
                          ? "Enter the verification code sent to ${_emailController.text}"
                          : "Enter your email address and we'll send you a verification code"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Different UI based on the current step
                  if (!_otpSent) ...[  
                    // Step 1: Email input
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
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Send OTP button
                    CustomButton(
                      text: "Send Verification Code",
                      onPressed: _sendOTP,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  ] else if (_otpSent && !_otpVerified) ...[  
                    // Step 2: OTP verification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        AppConstants.otpLength,
                        (index) => _buildOtpField(index),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Verify OTP button
                    CustomButton(
                      text: "Verify Code",
                      onPressed: _verifyOTP,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Resend code button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                        });
                      },
                      child: const Text(
                        "Change Email",
                        style: TextStyle(
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  ] else ...[  
                    // Step 3: New password input
                    CustomTextField(
                      label: "New Password",
                      hint: "Enter new password",
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        return null;
                      },
                      prefix: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.tertiaryTextColor,
                      ),
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.tertiaryTextColor,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                    
                    const SizedBox(height: 24),
                    
                    CustomTextField(
                      label: "Confirm Password",
                      hint: "Confirm new password",
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }
                        if (value != _newPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      prefix: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.tertiaryTextColor,
                      ),
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.tertiaryTextColor,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Reset password button
                    CustomButton(
                      text: "Reset Password",
                      onPressed: _resetPassword,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Back to login
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        color: AppTheme.goldColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
