import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/theme.dart';
import '../config/routes.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_service.dart';
import '../core/constants.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
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
      String? imageUrl =
          response['avatar_url'] ??
              user['avatar_url'] ??
              user['profile_image_url'];
      developer.log('Profile image URL: $imageUrl', name: 'MTI_Profile');

      setState(() {
        _nameController.text = user['full_name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phonenumber'] ?? '';
        _refCodeController.text = user['affiliate_code'] ?? '';
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
          developer.log(
            'Uploading profile image: ${_profileImage!.path}',
            name: 'MTI_Profile',
          );
          try {
            final imageResponse = await ApiService.updateProfileImage(
              _profileImage!.path,
            );
            developer.log(
              'Profile image upload response: $imageResponse',
              name: 'MTI_Profile',
            );
          } catch (imageError) {
            developer.log(
              'Error uploading profile image: $imageError',
              name: 'MTI_Profile',
              error: imageError,
            );
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
        developer.log(
          'Error updating profile: $e',
          name: 'MTI_Profile',
          error: e,
        );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarSize = (screenWidth * 0.28).clamp(90, 140).toDouble();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Profile",
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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //   onPressed: () => Get.toNamed(AppRoutes.settings),
        // ),
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
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (screenWidth * 0.05).clamp(16, 32).toDouble(),
                vertical: (screenHeight * 0.02).clamp(12, 28).toDouble(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Minimalist Edit Mode Chip
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child:
                    _isEditing
                        ? Container(
                      key: const ValueKey('edit_mode'),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit,
                            color: AppTheme.goldColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Edit Mode",
                            style: TextStyle(
                              color: AppTheme.goldColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                        : const SizedBox(height: 12),
                  ),
                  // Minimalist Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                        (screenWidth * 0.06).clamp(12, 22).toDouble(),
                        vertical:
                        (screenHeight * 0.03).clamp(12, 22).toDouble(),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile picture
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  width: avatarSize,
                                  height: avatarSize,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryBackgroundColor,
                                    borderRadius: BorderRadius.circular(
                                      avatarSize / 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child:
                                  _isLoading
                                      ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.goldColor,
                                    ),
                                  )
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      (avatarSize / 2) - 2,
                                    ),
                                    child: Builder(builder: (context) {
                                      // Handle profile image display based on source and platform
                                      if (_profileImage != null) {
                                        // For locally selected images
                                        if (kIsWeb) {
                                          // For web platform, we can't use Image.file directly
                                          // Just show a person icon until the image is uploaded and saved
                                          return Icon(
                                            Icons.person,
                                            size: avatarSize * 0.5,
                                            color: AppTheme.goldColor,
                                          );
                                        } else {
                                          // Mobile platforms can use Image.file
                                          return Image.file(
                                            File(_profileImage!.path),
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      } else if (_profileImageUrl != null &&
                                          _profileImageUrl!.isNotEmpty) {
                                        // For remote images
                                        developer.log('Loading profile image from URL: $_profileImageUrl', name: 'MTI_Profile');

                                        String imageUrl = _profileImageUrl!;

                                        // Make sure the URL is properly formatted for web
                                        if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
                                          if (kIsWeb) {
                                            // For web, we need to ensure the full URL is used
                                            // Usually the API returns a relative path like 'storage/avatars/filename.jpg'
                                            // First remove any leading slash for consistency
                                            if (imageUrl.startsWith('/')) {
                                              imageUrl = imageUrl.substring(1);
                                            }

                                            // Now prepend the base URL
                                            imageUrl = '${AppConstants.baseUrl}/${imageUrl}';
                                            developer.log('Web image URL: $imageUrl', name: 'MTI_Profile');
                                          } else {
                                            // For mobile, use standard path handling
                                            if (imageUrl.startsWith('/')) {
                                              imageUrl = '${AppConstants.baseUrl}${imageUrl}';
                                            } else {
                                              imageUrl = '${AppConstants.baseUrl}/${imageUrl}';
                                            }
                                          }
                                          developer.log('Final image URL: $imageUrl', name: 'MTI_Profile');
                                        }
                                        return Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                                color: AppTheme.goldColor,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            // Log error for debugging
                                            developer.log(
                                              'Error loading profile image: $error',
                                              name: 'MTI_Profile',
                                              error: error,
                                            );
                                            return Icon(
                                              Icons.person,
                                              size: avatarSize * 0.5,
                                              color: AppTheme.goldColor,
                                            );
                                          },
                                        );
                                      } else {
                                        // Fallback to icon when no image is available
                                        return Icon(
                                          Icons.person,
                                          size: avatarSize * 0.5,
                                          color: AppTheme.goldColor,
                                        );
                                      }
                                    }),
                                  ),
                                ),
                                if (_isEditing)
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.goldColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.goldColor
                                                  .withOpacity(0.18),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Name
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color:
                                _isEditing
                                    ? AppTheme.surfaceColor.withOpacity(
                                  0.10,
                                )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                    _isEditing
                                        ? AppTheme.goldColor.withOpacity(
                                      0.5,
                                    )
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: CustomTextField(
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
                              ),
                            ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                            const SizedBox(height: 14),
                            // Email
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color:
                                _isEditing
                                    ? AppTheme.surfaceColor.withOpacity(
                                  0.10,
                                )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                    _isEditing
                                        ? AppTheme.goldColor.withOpacity(
                                      0.5,
                                    )
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: CustomTextField(
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
                                suffix:
                                _isEditing
                                    ? IconButton(
                                  icon: const Icon(
                                    Icons.verified_outlined,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    Get.toNamed(
                                      AppRoutes.emailVerification,
                                      arguments: {
                                        'email': _emailController.text,
                                      },
                                    );
                                  },
                                )
                                    : null,
                              ),
                            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                            const SizedBox(height: 14),
                            // Phone
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color:
                                _isEditing
                                    ? AppTheme.surfaceColor.withOpacity(
                                  0.10,
                                )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                    _isEditing
                                        ? AppTheme.goldColor.withOpacity(
                                      0.5,
                                    )
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: CustomTextField(
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
                              ),
                            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                            const SizedBox(height: 14),
                            // Reference Code
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.goldColor.withOpacity(0.18),
                                    width: 1.1,
                                  ),
                                ),
                              ),
                              child: CustomTextField(
                                label: "Reference Code",
                                controller: _refCodeController,
                                enabled: false,
                                prefix: Icon(
                                  Icons.people_outline,
                                  color: AppTheme.goldColor.withOpacity(0.7),
                                ),
                                suffix: IconButton(
                                  icon: const Icon(
                                    Icons.copy,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: _refCodeController.text,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: const [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text("Reference code copied!"),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                            const SizedBox(height: 14),
                            // Address
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color:
                                _isEditing
                                    ? AppTheme.surfaceColor.withOpacity(
                                  0.10,
                                )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                    _isEditing
                                        ? AppTheme.goldColor.withOpacity(
                                      0.5,
                                    )
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: CustomTextField(
                                label: "Address",
                                controller: _addressController,
                                enabled: _isEditing,
                                maxLines: 3,
                                prefix: Icon(
                                  Icons.location_on_outlined,
                                  color: AppTheme.goldColor.withOpacity(0.7),
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                            const SizedBox(height: 14),
                            // USDT Address
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.goldColor.withOpacity(0.18),
                                    width: 1.1,
                                  ),
                                ),
                              ),
                              child: CustomTextField(
                                label: "USDT Address",
                                controller: _usdtAddressController,
                                enabled: false,
                                prefix: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppTheme.goldColor.withOpacity(0.7),
                                ),
                              ),
                            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                            const SizedBox(height: 28),
                            // Save button (only visible in edit mode)
                            if (_isEditing)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.goldColor.withOpacity(
                                        0.18,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  child:
                                  _isLoading
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.save,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(
                                delay: 700.ms,
                                duration: 500.ms,
                              ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
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
