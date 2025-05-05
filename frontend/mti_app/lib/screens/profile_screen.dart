import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'dart:io';
import '../config/theme.dart';
import '../config/routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _refCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _usdtAddressController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    developer.log('ProfileScreen initialized', name: 'MTI_Profile');
    _loadProfile();
  }

  String? _profileImageUrl;

  Future<void> _loadProfile() async {
    developer.log('Loading profile data', name: 'MTI_Profile');
    try {
      setState(() => _isLoading = true);
      final response = await ApiService.getProfile();
      final user = response['user'];
      
      developer.log('Profile data received: $user', name: 'MTI_Profile');
      
      // Get profile image URL - first check avatar_url in response, then fall back to profile_image_url attribute
      String? imageUrl = response['avatar_url'] ?? user['avatar_url'] ?? user['profile_image_url'];
      developer.log('Profile image URL: $imageUrl', name: 'MTI_Profile');
      
      setState(() {
        _nameController.text = user['full_name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phonenumber'] ?? '';
        _refCodeController.text = user['ref_code'] ?? '';
        _addressController.text = user['address'] ?? '';
        _usdtAddressController.text = user['usdt_address'] ?? '';
        _profileImageUrl = imageUrl;
        _profileImage = null; // Reset selected image when loading from server
      });
    } catch (e) {
      developer.log('Error loading profile: $e', name: 'MTI_Profile', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadProfile,
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    developer.log('Opening image picker', name: 'MTI_Profile');
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        developer.log('Image selected: ${image.path}', name: 'MTI_Profile');
        setState(() {
          _profileImage = image;
        });
      }
    } catch (e) {
      developer.log('Error picking image: $e', name: 'MTI_Profile', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      developer.log('Saving profile data', name: 'MTI_Profile');
      try {
        setState(() => _isLoading = true);

        // Handle profile image upload first if a new image was selected
        if (_profileImage != null) {
          developer.log('Uploading profile image: ${_profileImage!.path}', name: 'MTI_Profile');
          try {
            final imageResponse = await ApiService.updateProfileImage(_profileImage!.path);
            developer.log('Profile image upload response: $imageResponse', name: 'MTI_Profile');
          } catch (imageError) {
            developer.log('Error uploading profile image: $imageError', 
                name: 'MTI_Profile', error: imageError);
            // We'll continue with updating the other profile data even if image upload fails
          }
        }

        // Only include editable fields in the update data
        // Do not include reference_code and usdt_address as they cannot be updated
        final data = {
          'full_name': _nameController.text,
          'phonenumber': _phoneController.text,
          'address': _addressController.text,
        };

        developer.log('Profile update data: $data', name: 'MTI_Profile');
        await ApiService.updateProfile(data);

        // Reload profile to get updated data including new image URL
        await _loadProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _isEditing = false);
      } catch (e) {
        developer.log('Error updating profile: $e', name: 'MTI_Profile', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _saveProfile,
              textColor: Colors.white,
            ),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      developer.log('Profile form validation failed', name: 'MTI_Profile');
    }
  }

  @override
  void dispose() {
    developer.log('ProfileScreen disposed', name: 'MTI_Profile');
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _refCodeController.dispose();
    _addressController.dispose();
    _usdtAddressController.dispose();
    super.dispose();
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
          onPressed: () => Get.toNamed(AppRoutes.settings),
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
                          ),
                          child: _isLoading 
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.goldColor))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(58),
                                child: _profileImage != null
                                  // Show locally selected image if available
                                  ? Image.file(
                                      File(_profileImage!.path),
                                      fit: BoxFit.cover,
                                    )
                                  // Otherwise show server image if available
                                  : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                    ? Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                              color: AppTheme.goldColor,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppTheme.goldColor,
                                        ),
                                      )
                                    // If no image is available, show default icon
                                    : Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppTheme.goldColor,
                                      ),
                              ),
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
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // USDT Address
                  CustomTextField(
                    label: "USDT Address",
                    controller: _usdtAddressController,
                    enabled: false, // USDT address can't be changed
                    prefix: Icon(
                      Icons.account_balance_wallet_outlined,
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
