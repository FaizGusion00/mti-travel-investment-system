import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:email_otp/email_otp.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _referenceCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  DateTime? _selectedDate;
  XFile? _profileImage;
  bool _isLoading = false;
  bool _captchaVerified = false;
  String _captchaToken = '';
  final ImagePicker _picker = ImagePicker();
  final EmailOTP emailOTP = EmailOTP();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _referenceCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minimumAge = DateTime(now.year - 18, now.month, now.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? minimumAge,
      firstDate: DateTime(1950),
      lastDate: minimumAge,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.secondaryBackgroundColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Check if profile image is selected
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a profile picture'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      
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
        // Configure email OTP
        emailOTP.setConfig(
          appEmail: "mti.support@example.com",
          appName: "MTI Travel Investment",
          userEmail: _emailController.text,
          otpLength: 6,
          otpType: OTPType.digitsOnly,
        );
        
        // Send OTP
        await emailOTP.sendOTP();
        
        // Navigate to email verification screen
        Get.toNamed(
          AppRoutes.emailVerification,
          arguments: {'email': _emailController.text},
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create Account",
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
          physics: const BouncingScrollPhysics(), // Smooth scrolling for Android
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Picker
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryBackgroundColor,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: AppTheme.goldColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.goldColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _profileImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      File(_profileImage!.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 120,
                                          height: 120,
                                          color: AppTheme.secondaryBackgroundColor,
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: AppTheme.errorColor,
                                                size: 32,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Image Error",
                                                style: TextStyle(
                                                  color: AppTheme.secondaryTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: AppTheme.goldColor,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Add Photo",
                                        style: TextStyle(
                                          color: AppTheme.secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Profile Picture",
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Full Name
                  CustomTextField(
                    label: "Full Name",
                    hint: "Enter your full name",
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                    prefix: const Icon(
                      Icons.person_outline,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Email
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
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Phone
                  CustomTextField(
                    label: "Phone",
                    hint: "Enter your phone number",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      }
                      return null;
                    },
                    prefix: const Icon(
                      Icons.phone_outlined,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Date of Birth
                  CustomTextField(
                    label: "Date of Birth (18+ years old only)",
                    hint: "YYYY-MM-DD",
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Date of birth is required";
                      }
                      
                      try {
                        final dob = DateFormat('yyyy-MM-dd').parse(value);
                        final now = DateTime.now();
                        final age = now.year - dob.year - 
                          (now.month > dob.month || 
                          (now.month == dob.month && now.day >= dob.day) ? 0 : 1);
                          
                        if (age < 18) {
                          return "You must be at least 18 years old";
                        }
                      } catch (e) {
                        return "Invalid date format";
                      }
                      
                      return null;
                    },
                    prefix: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Password field
                  CustomTextField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: _passwordController,
                    obscureText: true,
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
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Confirm Password field
                  CustomTextField(
                    label: "Confirm Password",
                    hint: "Confirm your password",
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    prefix: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 550.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Reference Code
                  CustomTextField(
                    label: "Reference Code (Optional)",
                    hint: "Enter reference code",
                    controller: _referenceCodeController,
                    prefix: const Icon(
                      Icons.people_outline,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Captcha placeholder - will be replaced with Cloudflare Turnstile in production
                  Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Simulate captcha verification for development
                        // In production, this will be replaced with the actual Cloudflare Turnstile widget
                        // using AppConstants.cloudflareProdSiteKey
                        setState(() {
                          _captchaVerified = true;
                          _captchaToken = 'simulated-token-${DateTime.now().millisecondsSinceEpoch}';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Captcha verified successfully'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      },
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
                  ).animate().fadeIn(delay: 650.ms, duration: 500.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Register button
                  CustomButton(
                    text: "Create Account",
                    onPressed: _register,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
