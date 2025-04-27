import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String _email = '';
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _getEmailFromArguments();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _getEmailFromArguments() {
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('email')) {
      setState(() {
        _email = args['email'];
      });
    } else {
      // Handle missing email (redirect back or show error)
      Get.snackbar(
        'Error',
        'Email information missing. Please try again.',
        backgroundColor: AppTheme.errorColor.withOpacity(0.9),
        colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.verifyOtp(_email, _otpController.text);

        if (response['success'] == true) {
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar(
            'Success',
            'Email verified successfully. You can now login.',
            backgroundColor: AppTheme.successColor.withOpacity(0.9),
            colorText: Colors.white,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Verification failed'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } catch (e) {
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
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final response = await _apiService.resendOtp(_email);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully. Please check your email.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {
          _resendTimer = 60;
        });
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to resend OTP'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isResending = false;
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
        title: Text(
          "Email Verification",
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.goldColor,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Verify Your Email",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "We've sent a verification code to",
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // OTP field
                  CustomTextField(
                    label: "Enter Verification Code",
                    hint: "6-digit code",
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      letterSpacing: 8,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter verification code";
                      }
                      if (value.length != 6 || !GetUtils.isNumericOnly(value)) {
                        return "Please enter a valid 6-digit code";
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Resend OTP link
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
                        onPressed: _resendTimer == 0 ? _resendOtp : null,
                        child: Text(
                          _resendTimer > 0 
                            ? "Resend in ${_resendTimer}s" 
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
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Verify button
                  CustomButton(
                    text: "Verify",
                    onPressed: _verifyOtp,
                    isLoading: _isLoading,
                    width: double.infinity,
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
