import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "John Doe");
  final _emailController = TextEditingController(text: "john.doe@example.com");
  final _phoneController = TextEditingController(text: "+1 234 567 8901");
  final _refCodeController = TextEditingController(text: "MTI12345");
  final _usdtAddressController = TextEditingController(text: "0x1234...5678");
  final _addressController = TextEditingController(text: "123 Crypto Street, Blockchain City");
  
  bool _isEditing = false;
  bool _isLoading = false;
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _refCodeController.dispose();
    _usdtAddressController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Smooth scrolling for Android
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        Container(
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
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: NetworkImage(_profileImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profileImage == null
                              ? Icon(
                                  Icons.person,
                                  color: AppTheme.goldColor,
                                  size: 60,
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppTheme.backgroundColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.goldColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Name
                  CustomTextField(
                    label: "Full Name",
                    controller: _nameController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                    prefix: Icon(
                      Icons.person_outline,
                      color: AppTheme.goldColor.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Email
                  CustomTextField(
                    label: "Email",
                    controller: _emailController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!GetUtils.isEmail(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                    prefix: Icon(
                      Icons.email_outlined,
                      color: AppTheme.goldColor.withOpacity(0.7),
                    ),
                    suffix: _isEditing
                        ? IconButton(
                            icon: const Icon(
                              Icons.verified_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: () {
                              // Show email verification dialog
                              Get.toNamed(
                                AppRoutes.emailVerification,
                                arguments: {'email': _emailController.text},
                              );
                            },
                          )
                        : null,
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Phone
                  CustomTextField(
                    label: "Phone",
                    controller: _phoneController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone is required";
                      }
                      return null;
                    },
                    prefix: Icon(
                      Icons.phone_outlined,
                      color: AppTheme.goldColor.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Reference Code
                  CustomTextField(
                    label: "Reference Code",
                    controller: _refCodeController,
                    enabled: false, // Reference code can't be changed
                    prefix: Icon(
                      Icons.people_outline,
                      color: AppTheme.goldColor.withOpacity(0.7),
                    ),
                    suffix: IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reference code copied to clipboard'),
                            backgroundColor: AppTheme.infoColor,
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // USDT BEP20 Address
                  CustomTextField(
                    label: "USDT BEP20 Address",
                    controller: _usdtAddressController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "USDT address is required";
                      }
                      return null;
                    },
                    prefix: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppTheme.goldColor.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Address
                  CustomTextField(
                    label: "Address",
                    controller: _addressController,
                    enabled: _isEditing,
                    maxLines: 3,
                    prefix: Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.goldColor.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Save button (only visible in edit mode)
                  if (_isEditing)
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ),
      ),
      // No bottom navigation bar since this is accessed from settings
    );
  }
}
