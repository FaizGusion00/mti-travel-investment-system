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
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  
  String _status = "";

  bool _isEditing = false;
  bool _isLoading = false;
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String? _newEmail;
  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    developer.log('ProfileScreen initialized', name: 'MTI_Profile');
    _loadProfile();
  }

  String? _profileImageUrl;

  // Helper function to capitalize first letter of status
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Helper function to get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  // Format date for display
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      // Display as dd-MM-yyyy
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  // Helper function to copy text to clipboard - fixed version
  void _copyToClipboard(String text, String fieldName) {
    developer.log('Attempting to copy to clipboard: "$text"', name: 'MTI_Clipboard');
    
    if(text.isEmpty) {
      developer.log('Nothing to copy - text is empty', name: 'MTI_Clipboard');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(
                Icons.warning,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text("Nothing to copy!"),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    try {
      // Use synchronous operation with FlutterClipboard
      Clipboard.setData(ClipboardData(text: text));
      developer.log('Text copied to clipboard successfully', name: 'MTI_Clipboard');
      
      // Use a small delay to ensure UI update completes before showing snackbar
      Future.delayed(Duration.zero, () {
        if (mounted) {
          developer.log('Showing success snackbar', name: 'MTI_Clipboard');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text("$fieldName copied to clipboard!"),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          developer.log('Widget no longer mounted, cannot show snackbar', name: 'MTI_Clipboard');
        }
      });
    } catch (error) {
      developer.log('Error copying to clipboard: $error', name: 'MTI_Clipboard', error: error);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(child: Text("Failed to copy: $error")),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

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
        _originalEmail = user['email']; // Store original email
        _phoneController.text = user['phonenumber'] ?? '';
        _refCodeController.text = user['affiliate_code'] ?? '';
        _addressController.text = user['address'] ?? '';
        _usdtAddressController.text = user['usdt_address'] ?? '';
        _usernameController.text = user['username'] ?? '';
        
        // Format date of birth properly
        if (user['date_of_birth'] != null) {
          _dobController.text = _formatDate(user['date_of_birth']);
        } else {
          _dobController.text = '';
        }
        
        _status = user['status'] ?? 'Active';
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

  Future<void> _validateAndUpdateEmail() async {
    if (_newEmail == null || _newEmail!.isEmpty || _newEmail == _originalEmail) {
      return;
    }
    
    try {
      setState(() => _isLoading = true);
      
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sending verification code...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      
      // Request OTP for email verification
      final response = await ApiService.updateEmail({
        'email': _newEmail,
      });
      
      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      developer.log('Email verification requested: $response', name: 'MTI_Profile');
      
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to request verification code');
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Verification code sent to your new email"),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Navigate to email verification screen
      bool? verified = await Get.toNamed(
        AppRoutes.emailVerification,
        arguments: {
          'email': _newEmail,
          'isUpdate': true,
        },
      );
      
      if (verified == true) {
        // Email successfully verified
        developer.log('Email verified successfully', name: 'MTI_Profile');
        setState(() {
          _emailController.text = _newEmail!;
          _newEmail = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Email updated and verified successfully"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        // Email verification failed or was cancelled
        developer.log('Email verification failed or cancelled', name: 'MTI_Profile');
        setState(() {
          _emailController.text = _originalEmail!;
          _newEmail = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text("Email update cancelled or verification failed"),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      // Close the loading dialog if it's still open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      developer.log('Error requesting email verification: $e', name: 'MTI_Profile', error: e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Flexible(
                child: Text('Failed to update email: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _validateAndUpdateEmail,
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      developer.log('Saving profile data', name: 'MTI_Profile');
      try {
        setState(() => _isLoading = true);

        // Check if email was changed
        if (_emailController.text != _originalEmail) {
          _newEmail = _emailController.text;
          _emailController.text = _originalEmail!; // Reset to original until verified
        }

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

        // Prepare profile data
        final data = {
          'full_name': _nameController.text,
          'username': _usernameController.text,
          'phonenumber': _phoneController.text,
          'address': _addressController.text,
          'date_of_birth': _dobController.text,
        };

        developer.log('Profile update data: $data', name: 'MTI_Profile');
        await ApiService.updateProfile(data);

        // Reload profile to get updated data including new image URL
        await _loadProfile();

        // If email was changed, start verification process
        if (_newEmail != null) {
          await _validateAndUpdateEmail();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
    _usernameController.dispose();
    _dobController.dispose();
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
          child: RefreshIndicator(
            onRefresh: _loadProfile,
            color: AppTheme.goldColor,
            backgroundColor: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                          BoxShadow(
                            color: AppTheme.goldColor.withOpacity(0.05),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.goldColor.withOpacity(0.15),
                          width: 0.5,
                        ),
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
                                  // Gold gradient ring behind avatar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: avatarSize + 10,
                                    height: avatarSize + 10,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.goldGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.goldColor.withOpacity(0.25),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
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
                              // Full Name
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
                              // Username
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
                                  label: "Username",
                                  controller: _usernameController,
                                  enabled: _isEditing,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Username is required";
                                    }
                                    return null;
                                  },
                                  prefix: Icon(
                                    Icons.account_circle_outlined,
                                    color: AppTheme.goldColor.withOpacity(0.7),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
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
                                  suffix: _isEditing
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Tooltip(
                                              message: "Email verification required for changes",
                                              child: Icon(
                                                Icons.info_outline,
                                                color: AppTheme.goldColor.withOpacity(0.7),
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: AppTheme.goldGradient,
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.goldColor.withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (_emailController.text != _originalEmail) {
                                                      // Store new email for verification after save
                                                      _newEmail = _emailController.text;
                                                      
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Row(
                                                            children: const [
                                                              Icon(
                                                                Icons.info,
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(width: 10),
                                                              Text("Email will be verified after saving profile"),
                                                            ],
                                                          ),
                                                          backgroundColor: Colors.blue,
                                                          duration: const Duration(seconds: 3),
                                                          behavior: SnackBarBehavior.floating,
                                                          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Row(
                                                            children: const [
                                                              Icon(
                                                                Icons.info,
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(width: 10),
                                                              Text("No changes to email detected"),
                                                            ],
                                                          ),
                                                          backgroundColor: Colors.orange,
                                                          duration: const Duration(seconds: 2),
                                                          behavior: SnackBarBehavior.floating,
                                                          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    child: Text(
                                                      "Verify",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () async {
                                      final text = _emailController.text;
                                      if (text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Nothing to copy!"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      await Clipboard.setData(ClipboardData(text: text));
                                      if (!mounted) return;
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Email copied to clipboard!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(
                                begin: -0.1, 
                                end: 0, 
                                duration: 700.ms, 
                                curve: Curves.easeOutQuint
                              ),
                              const SizedBox(height: 14),
                              // Date of Birth
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
                                  label: "Date of Birth",
                                  controller: _dobController,
                                  enabled: _isEditing,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Date of birth is required";
                                    }
                                    return null;
                                  },
                                  prefix: Icon(
                                    Icons.cake_outlined,
                                    color: AppTheme.goldColor.withOpacity(0.7),
                                  ),
                                  suffix: _isEditing ? IconButton(
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: _dobController.text.isNotEmpty
                                            ? DateTime.parse(_dobController.text)
                                            : DateTime.now().subtract(const Duration(days: 365 * 18)),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.dark(
                                                primary: AppTheme.goldColor,
                                                onPrimary: Colors.white,
                                                surface: AppTheme.surfaceColor,
                                                onSurface: Colors.white,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      
                                      if (picked != null) {
                                        setState(() {
                                          _dobController.text = picked.toString().split(' ')[0];
                                        });
                                      }
                                    },
                                  ) : null,
                                ),
                              ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideX(
                                begin: 0.1, 
                                end: 0, 
                                duration: 700.ms, 
                                curve: Curves.easeOutQuint
                              ),
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
                                  suffix: !_isEditing ? IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () async {
                                      final text = _phoneController.text;
                                      if (text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Nothing to copy!"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      await Clipboard.setData(ClipboardData(text: text));
                                      if (!mounted) return;
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Phone number copied to clipboard!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ) : null,
                                ),
                              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(
                                begin: -0.1, 
                                end: 0, 
                                duration: 700.ms, 
                                curve: Curves.easeOutQuint
                              ),
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
                                      final text = _refCodeController.text;
                                      if (text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Nothing to copy!"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      await Clipboard.setData(ClipboardData(text: text));
                                      if (!mounted) return;
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Reference code copied to clipboard!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideX(
                                begin: 0.1, 
                                end: 0, 
                                duration: 700.ms, 
                                curve: Curves.easeOutQuint
                              ),
                              const SizedBox(height: 14),
                              // Status (only shown in view mode)
                              if (!_isEditing)
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
                                    label: "Status",
                                    controller: TextEditingController(text: _capitalizeFirstLetter(_status)),
                                    enabled: false,
                                    prefix: Icon(
                                      Icons.verified_user_outlined,
                                      color: AppTheme.goldColor.withOpacity(0.7),
                                    ),
                                    style: TextStyle(
                                      color: _getStatusColor(_status),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 450.ms, duration: 500.ms).slideY(
                                  begin: 0.2, 
                                  duration: 600.ms, 
                                  curve: Curves.easeOutQuart
                                ),
                              if (!_isEditing) const SizedBox(height: 14),
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
                                child: _isEditing 
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
                                      child: Text(
                                        "Address",
                                        style: TextStyle(
                                          color: AppTheme.goldColor.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16, 
                                        right: 16, 
                                        bottom: 12
                                      ),
                                      child: TextField(
                                  controller: _addressController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                  maxLines: 3,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: AppTheme.goldColor.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: AppTheme.goldColor.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: AppTheme.goldColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          hintText: "Enter your address",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.location_on_outlined,
                                            color: AppTheme.goldColor.withOpacity(0.7),
                                            size: 20,
                                          ),
                                          filled: true,
                                          fillColor: AppTheme.surfaceColor.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : CustomTextField(
                                  label: "Address",
                                  controller: _addressController,
                                  enabled: false,
                                  maxLines: _addressController.text.length > 30 ? 2 : 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  prefix: Icon(
                                    Icons.location_on_outlined,
                                    color: AppTheme.goldColor.withOpacity(0.7),
                                  ),
                                  suffix: IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () async {
                                      final text = _addressController.text;
                                      if (text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Nothing to copy!"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      await Clipboard.setData(ClipboardData(text: text));
                                      if (!mounted) return;
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Address copied to clipboard!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(
                                begin: 0.2, 
                                end: 0, 
                                duration: 800.ms, 
                                curve: Curves.easeOutQuint
                              ),
                              const SizedBox(height: 14),
                              // USDT Address (only shown in view mode)
                              if (!_isEditing)
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
                                    suffix: IconButton(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: AppTheme.primaryColor,
                                      ),
                                      onPressed: () async {
                                        final text = _usdtAddressController.text;
                                        if (text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Nothing to copy!"),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }
                                        
                                        await Clipboard.setData(ClipboardData(text: text));
                                        if (!mounted) return;
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("USDT Address copied to clipboard!"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(
                                  begin: 0.2, 
                                  end: 0, 
                                  duration: 800.ms,
                                  curve: Curves.easeOutQuint
                                ),
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
                                ).scale(
                                  delay: 700.ms,
                                  duration: 400.ms,
                                  begin: const Offset(0.95, 0.95),
                                  end: const Offset(1.0, 1.0),
                                  curve: Curves.easeOutBack
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
      ),
      // No bottom navigation bar since this is accessed from settings
    );
  }
}
