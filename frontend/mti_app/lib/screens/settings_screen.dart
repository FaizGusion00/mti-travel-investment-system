import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, kReleaseMode;
import '../config/theme.dart';
import '../config/routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../core/constants.dart';
import 'package:shimmer/shimmer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';
  String _appVersion = 'v0.0.3';
  bool _isLoading = false;
  String? _profileImageUrl;
  bool _isButtonPressed = false;
  
  // Auth service
  final AuthService _authService = AuthService();
  
  // Profile information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadUserProfile();
  }
  
  Future<void> _getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}';
      });
    } catch (e) {
      // Use default version if package info fails
      setState(() {
        _appVersion = 'v0.0.3';
      });
    }
  }

  // Helper function to format image URLs correctly for both web and mobile
  String getFormattedImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // If URL already starts with http:// or https://, it's already a full URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Remove leading slash if present for consistency
    final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;

    // For web, we need the full absolute URL
    if (kIsWeb) {
      // Use window.location.origin to get the current domain
      // or fallback to the baseUrl from AppConstants
      final baseUrl = AppConstants.baseUrl;
      developer.log('Web image URL created: $baseUrl/$cleanPath', name: 'MTI_Settings');
      return '$baseUrl/$cleanPath';
    } else {
      // For mobile, prepend the base URL
      return '${AppConstants.baseUrl}/$cleanPath';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarSize = (screenWidth * 0.24).clamp(80, 120).toDouble();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth * 0.05).clamp(16, 32).toDouble(),
            vertical: (screenHeight * 0.02).clamp(12, 28).toDouble(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(screenWidth, avatarSize),
              const SizedBox(height: 24),
              _buildSectionTitle('ACCOUNT'),
              _buildSettingsItem(
                'Transaction History',
                Icons.receipt_long_outlined,
                onTap: () => Get.toNamed(AppRoutes.transactionHistory),
              ),
              // _buildCurrencyPreference(screenWidth),
              // _buildDarkModeToggle(screenWidth),
              const SizedBox(height: 24),
              _buildSectionTitle('OTHER'),
              _buildSettingsItem(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
              ),
              _buildSettingsItem(
                'Terms & Conditions',
                Icons.description_outlined,
                onTap: () => Get.toNamed(AppRoutes.termsConditions),
              ),
              _buildSettingsItem(
                'Contact Us',
                Icons.support_agent_outlined,
                onTap: () => Get.toNamed(AppRoutes.contactUs),
              ),
              // Debug mode item (only visible in debug/profile mode, hidden in release mode)
              if (!kReleaseMode)
                _buildSettingsItem(
                  'Debug Settings',
                  Icons.developer_mode,
                  onTap: () {
                    // Navigate to debug screen with proper error handling
                    try {
                      Get.toNamed(AppRoutes.debug);
                    } catch (e) {
                      developer.log('Error navigating to debug screen: $e', name: 'MTI_Settings', error: e);
                      Get.snackbar(
                        'Navigation Error', 
                        'Could not open debug screen: ${e.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.7),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 5),
                      );
                    }
                  },
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DEV',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              _buildSettingsItem(
                'App Version',
                Icons.info_outline,
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: AppTheme.secondaryBackgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('App Version', style: TextStyle(color: Colors.white)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/mti_logo.png',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _appVersion,
                            style: TextStyle(color: AppTheme.goldColor, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            ' 2025 MTI Travel Investment',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Close', style: TextStyle(color: AppTheme.goldColor)),
                        ),
                      ],
                    ),
                  );
                },
                trailing: Text(
                  _appVersion,
                  style: const TextStyle(
                    color: AppTheme.tertiaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.goldColor.withOpacity(0.85),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    {required VoidCallback onTap, Widget? trailing}
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerColor.withOpacity(0.18),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.goldColor,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            trailing ?? const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.tertiaryTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  // Widget _buildCurrencyPreference(double screenWidth) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 14),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(
  //           color: AppTheme.dividerColor.withOpacity(0.18),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(
  //           Icons.attach_money,
  //           color: AppTheme.goldColor,
  //           size: 22,
  //         ),
  //         const SizedBox(width: 16),
  //         const Expanded(
  //           child: Text(
  //             'Currency Preference',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 15,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: () {
  //             // Show currency selection dialog
  //             Get.dialog(
  //               AlertDialog(
  //                 backgroundColor: AppTheme.cardColor,
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //                 title: const Text('Select Currency', style: TextStyle(color: Colors.white)),
  //                 content: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     _buildCurrencyOption('USD'),
  //                     _buildCurrencyOption('EUR'),
  //                     _buildCurrencyOption('MYR'),
  //                   ],
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () => Get.back(),
  //                     child: Text('Close', style: TextStyle(color: AppTheme.goldColor)),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //             decoration: BoxDecoration(
  //               color: AppTheme.secondaryBackgroundColor,
  //               borderRadius: BorderRadius.circular(20),
  //               border: Border.all(
  //                 color: AppTheme.goldColor.withOpacity(0.3),
  //                 width: 1,
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 Text(
  //                   _selectedCurrency,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 4),
  //                 const Icon(
  //                   Icons.arrow_drop_down,
  //                   color: AppTheme.goldColor,
  //                   size: 20,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  // }

  Widget _buildCurrencyOption(String currency) {
    return ListTile(
      title: Text(
        currency,
        style: TextStyle(
          color: _selectedCurrency == currency ? AppTheme.goldColor : Colors.white,
          fontWeight: _selectedCurrency == currency ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: _selectedCurrency == currency
          ? const Icon(Icons.check, color: AppTheme.goldColor)
          : null,
      onTap: () {
        setState(() {
          _selectedCurrency = currency;
        });
        Get.back();
      },
    );
  }

  Widget _buildDarkModeToggle(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withOpacity(0.18),
            width: 1,
          ),
        ),
      ),
      // child: Row(
      //   children: [
      //     const Icon(
      //       Icons.dark_mode_outlined,
      //       color: AppTheme.goldColor,
      //       size: 22,
      //     ),
      //     const SizedBox(width: 16),
      //     const Expanded(
      //       child: Text(
      //         'Dark Mode',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontSize: 15,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //     ),
      //     Switch(
      //       value: _isDarkMode,
      //       onChanged: (value) {
      //         setState(() {
      //           _isDarkMode = value;
      //         });
      //       },
      //       activeColor: AppTheme.goldColor,
      //       activeTrackColor: AppTheme.goldColor.withOpacity(0.3),
      //       inactiveThumbColor: Colors.grey,
      //       inactiveTrackColor: Colors.grey.withOpacity(0.3),
      //     ),
      //   ],
      // ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildProfileSection(double screenWidth, double avatarSize) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.profile);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: (screenWidth * 0.04).clamp(12, 20).toDouble(),
          vertical: 22,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.22),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldColor.withOpacity(0.13),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Picture
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.goldColor,
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldColor.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(avatarSize / 2),
                child: Builder(builder: (context) {
                  if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
                    // Log the URL being used for debugging
                    developer.log(
                      'Attempting to load profile image from URL: $_profileImageUrl',
                      name: 'MTI_Settings',
                    );
                    
                    // Log the URL being used for debugging
                    String imageUrl = getFormattedImageUrl(_profileImageUrl);
                    
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          developer.log(
                            'Profile image loaded successfully',
                            name: 'MTI_Settings',
                          );
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Log detailed error information
                        developer.log(
                          'Error loading profile image: $error',
                          name: 'MTI_Settings',
                          error: error,
                        );
                        developer.log(
                          'Image URL that failed: $_profileImageUrl',
                          name: 'MTI_Settings',
                        );
                        
                        return Icon(
                          Icons.person,
                          size: avatarSize * 0.5,
                          color: AppTheme.goldColor,
                        );
                      },
                    );
                  } else {
                    // No profile image URL available
                    return Icon(
                      Icons.person,
                      size: avatarSize * 0.5,
                      color: AppTheme.goldColor,
                    );
                  }
                }),
              ),
            ),
            const SizedBox(height: 18),
            // Name Field
            _buildProfileField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            // Email Field
            _buildProfileField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            // Phone Field
            _buildProfileField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            // const SizedBox(height: 20),
            // Minimalist View Profile Button
            // GestureDetector(
            //   onTapDown: (_) => setState(() => _isButtonPressed = true),
            //   onTapUp: (_) => setState(() => _isButtonPressed = false),
            //   onTapCancel: () => setState(() => _isButtonPressed = false),
            //   onTap: () {
            //     Get.toNamed(AppRoutes.profile);
            //   },
            //   child: AnimatedOpacity(
            //     duration: const Duration(milliseconds: 120),
            //     opacity: _isButtonPressed ? 0.7 : 1.0,
            //     child: AnimatedScale(
            //       duration: const Duration(milliseconds: 120),
            //       scale: _isButtonPressed ? 0.97 : 1.0,
            //       child: Container(
            //         width: double.infinity,
            //         height: 44,
            //         decoration: BoxDecoration(
            //           color: Colors.transparent,
            //           borderRadius: BorderRadius.circular(12),
            //           border: Border.all(
            //             color: AppTheme.goldColor,
            //             width: 1.6,
            //           ),
            //         ),
            //         child: Center(
            //           child: Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: const [
            //               Icon(
            //                 Icons.person_outline,
            //                 color: AppTheme.goldColor,
            //                 size: 20,
            //               ),
            //               SizedBox(width: 8),
            //               Text(
            //                 'View My Profile',
            //                 style: TextStyle(
            //                   color: AppTheme.goldColor,
            //                   fontSize: 15,
            //                   fontWeight: FontWeight.w700,
            //                   letterSpacing: 0.2,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
      begin: 0.1,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutQuad,
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.goldColor,
            size: 19,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserProfile() async {
    developer.log('Loading profile data for settings screen', name: 'MTI_Settings');
    try {
      setState(() => _isLoading = true);
      final response = await ApiService.getProfile();
      final user = response['user'];
      
      developer.log('Profile data received: $user', name: 'MTI_Settings');
      
      // Get profile image URL - first check avatar_url in response, then fall back to profile_image_url attribute
      String? imageUrl = response['avatar_url'] ?? user['avatar_url'] ?? user['profile_image_url'];
      developer.log('Profile image URL: $imageUrl', name: 'MTI_Settings');
      
      setState(() {
        _nameController.text = user['full_name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phonenumber'] ?? '';
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      developer.log('Error loading profile for settings screen: $e', name: 'MTI_Settings', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadUserProfile,
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLogoutButton(double screenWidth) {
    return TextButton(
      onPressed: () {
        Get.dialog(
          AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                      ),
                    ),
                    barrierDismissible: false,
                  );
                  try {
                    await _authService.logout();
                    Get.back();
                    Get.offAllNamed(AppRoutes.login);
                  } catch (e) {
                    Get.back();
                    Get.snackbar(
                      'Error',
                      'Failed to logout: ${e.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.errorColor.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "Logout",
            style: TextStyle(
              color: AppTheme.errorColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
