import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // Simulate API call with a delay
      await Future.delayed(Duration(seconds: 2));
      
      // Success
      setState(() => _isSubmitting = false);
      
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      
      // Show success message
      Get.snackbar(
        'Success',
        'Your message has been sent successfully. We\'ll get back to you soon.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      developer.log('Error submitting contact form: $e');
      setState(() => _isSubmitting = false);
      
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.7),
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
      );
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      developer.log('Error launching URL: $e');
      Get.snackbar(
        'Error',
        'Could not open link. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader().animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 25),
                _buildContactInfo().animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 25),
                _buildContactForm().animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 30),
                _buildSocialMedia().animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      // No bottom navigation bar for settings pages
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.goldColor.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          child: Text(
            'Get In Touch',
            style: TextStyle(
              color: AppTheme.goldColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Have questions or need assistance? We\'re here to help! Contact our support team through any of the methods below or fill out the contact form.',
          style: TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.cardColor.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email Us',
            content: 'support@mti-travel.com',
            onTap: () => _launchURL('mailto:support@mti-travel.com'),
          ),
          Divider(color: AppTheme.dividerColor, height: 20),
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            content: '+1 (888) 123-4567',
            onTap: () => _launchURL('tel:+18881234567'),
          ),
          Divider(color: AppTheme.dividerColor, height: 20),
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Visit Us',
            content: '123 Investment Avenue, Financial District, New York, NY 10001',
            onTap: () => _launchURL('https://maps.google.com/?q=Financial+District+New+York'),
          ),
          Divider(color: AppTheme.dividerColor, height: 20),
          _buildContactItem(
            icon: Icons.access_time_outlined,
            title: 'Business Hours',
            content: 'Monday to Friday: 9:00 AM - 5:00 PM EST',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.goldColor,
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.goldColor,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.cardColor.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Us a Message',
              style: TextStyle(
                color: AppTheme.goldColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icons.email_outlined,
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _messageController,
              decoration: _inputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message',
                prefixIcon: Icons.message_outlined,
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: AppTheme.goldColor.withOpacity(0.7)),
      labelStyle: TextStyle(color: AppTheme.secondaryTextColor),
      hintStyle: TextStyle(color: AppTheme.secondaryTextColor.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.goldColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      filled: true,
      fillColor: AppTheme.cardColor.withOpacity(0.7),
    );
  }

  Widget _buildSocialMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSocialButton(
              icon: Icons.facebook,
              color: Color(0xFF1877F2),
              onTap: () => _launchURL('https://facebook.com'),
            ),
            _buildSocialButton(
              icon: Icons.facebook,
              iconPath: 'assets/icons/twitter.png',
              color: Color(0xFF1DA1F2),
              onTap: () => _launchURL('https://twitter.com'),
            ),
            _buildSocialButton(
              icon: Icons.camera_alt,
              color: Color(0xFFE1306C),
              onTap: () => _launchURL('https://instagram.com'),
            ),
            _buildSocialButton(
              icon: Icons.messenger_outline,
              color: Color(0xFF0088CC),
              onTap: () => _launchURL('https://t.me'),
            ),
            _buildSocialButton(
              icon: Icons.play_arrow,
              color: Color(0xFFFF0000),
              onTap: () => _launchURL('https://youtube.com'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    String? iconPath,
    required Color color,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: iconPath != null
            ? Image.asset(iconPath, width: 24, height: 24, color: color)
            : Icon(icon, color: color, size: 24),
      ),
    ).animate()
      .scale(
        duration: 200.ms,
        begin: Offset(1, 1),
        end: Offset(1.1, 1.1),
        curve: Curves.easeInOut,
      ).then()
      .scale(
        duration: 200.ms,
        begin: Offset(1.1, 1.1),
        end: Offset(1, 1),
        curve: Curves.easeInOut,
      );
  }
}
