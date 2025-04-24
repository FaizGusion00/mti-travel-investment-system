import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../core/constants.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  late String _email;
  int _resendTimer = 60;
  Timer? _timer;
  bool _isLoading = false;
  EmailOTP emailOTP = EmailOTP();

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? args = Get.arguments;
    _email = args?['email'] ?? 'your email';
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = AppConstants.resendOtpTimerSeconds;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    if (_resendTimer > 0) return;
    
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
        userEmail: _email,
        otpLength: AppConstants.otpLength,
        otpType: OTPType.digitsOnly,
      );
      
      // Send OTP
      await emailOTP.sendOTP();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent successfully'),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      _startResendTimer();
    }
  }

  Future<void> _verifyOtp() async {
    // Combine all OTP digits
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    // Validate OTP length
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
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
        // Navigate to home screen on successful verification
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid verification code. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          "Email Verification",
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
          physics: const BouncingScrollPhysics(), // Smooth scrolling for Android
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Email verification illustration
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryColor,
                    size: 60,
                  ),
                ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
                
                const SizedBox(height: 32),
                
                // Title and description
                Text(
                  "Verify your email",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  "We've sent a 6-digit verification code to $_email",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 16,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                
                const SizedBox(height: 48),
                
                // OTP input fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => _buildOtpField(index),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                
                const SizedBox(height: 48),
                
                // Verify button
                CustomButton(
                  text: "Verify",
                  onPressed: _verifyOtp,
                  isLoading: _isLoading,
                  width: double.infinity,
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                
                const SizedBox(height: 32),
                
                // Resend code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _resendTimer > 0 ? null : _resendCode,
                      child: Text(
                        _resendTimer > 0
                            ? "Resend in $_resendTimer s"
                            : "Resend Code",
                        style: TextStyle(
                          color: _resendTimer > 0
                              ? AppTheme.tertiaryTextColor
                              : AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? AppTheme.goldColor
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: _focusNodes[index].hasFocus ? [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last field, hide keyboard
              FocusManager.instance.primaryFocus?.unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Move to previous field on backspace
            _focusNodes[index - 1].requestFocus();
          }
        },
        onTap: () {
          // Select all text when tapped
          _otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index].text.length,
          );
        },
      ),
    );
  }
}
