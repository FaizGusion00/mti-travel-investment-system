import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:package_info_plus/package_info_plus.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';
  String _appVersion = 'v0.0.2';
  bool _isLoading = false;
  String? _profileImageUrl;
  
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
        _appVersion = 'v0.0.2';
      });
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('ACCOUNT'),
              _buildCurrencyPreference(),
              _buildDarkModeToggle(),
              _buildLanguagePreference(),
              
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
              
              // App version
              _buildSettingsItem(
                'App Version',
                Icons.info_outline,
                onTap: () {
                  // Show version info dialog
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
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
      // No bottom navigation bar since this is accessed from profile
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.goldColor.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildCurrencyPreference() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_money,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Currency Preference',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.goldColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _selectedCurrency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.goldColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildDarkModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.dark_mode_outlined,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
            activeColor: AppTheme.goldColor,
            activeTrackColor: AppTheme.goldColor.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildLanguagePreference() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.language_outlined,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'App Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _selectedLanguage,
              style: const TextStyle(
                color: AppTheme.tertiaryTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () {
        // Navigate to profile screen
        Get.toNamed(AppRoutes.profile);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Picture
            Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.goldColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _profileImageUrl != null
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
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.goldColor,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.goldColor,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.backgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Name Field
          _buildProfileField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          
          // Email Field
          _buildProfileField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          // Phone Field
          _buildProfileField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          
          // View Profile Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.goldColor,
                  Color(0xFFD4AF37),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to profile screen
                Get.toNamed(AppRoutes.profile);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'View Full Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )).animate().fadeIn(duration: 500.ms).slideY(
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
        color: AppTheme.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.goldColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
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

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: () {
        // Show logout confirmation dialog
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
                  
                  // Show loading indicator
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                      ),
                    ),
                    barrierDismissible: false,
                  );
                  
                  // Call logout from AuthService
                  try {
                    await _authService.logout();
                    Get.back(); // Close loading dialog
                    Get.offAllNamed(AppRoutes.login);
                  } catch (e) {
                    Get.back(); // Close loading dialog
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
