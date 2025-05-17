import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../shared/widgets/bottom_nav_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Privacy Policy',
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
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeading('Meta Travel International Privacy Policy')
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 20),
                _buildSection(
                  'Introduction',
                  'Meta Travel International ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application ("App"). Please read this Privacy Policy carefully. By using the App, you consent to the practices described in this policy.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Information We Collect',
                  'We may collect personal information that you provide directly to us, including but not limited to:\n\n'
                  '• Personal identifiers such as your name, email address, phone number, and date of birth\n'
                  '• Account credentials such as your password\n'
                  '• Financial information such as bank details and payment information\n'
                  '• Profile information such as your profile picture, address, and preferences\n'
                  '• Any other information you choose to provide\n\n'
                  'We may also collect information automatically when you use our App, including your device information, IP address, usage data, and location data (if you grant permission).',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'How We Use Your Information',
                  'We may use the information we collect for various purposes, including to:\n\n'
                  '• Provide, maintain, and improve our App\n'
                  '• Process transactions and manage your account\n'
                  '• Send you technical notices, updates, security alerts, and support messages\n'
                  '• Respond to your comments, questions, and customer service requests\n'
                  '• Communicate with you about products, services, offers, and promotions\n'
                  '• Monitor and analyze trends, usage, and activities in connection with our App\n'
                  '• Detect, investigate, and prevent fraudulent transactions and other illegal activities\n'
                  '• Comply with legal obligations',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Information Sharing and Disclosure',
                  'We may share your information in the following circumstances:\n\n'
                  '• With service providers who perform services on our behalf\n'
                  '• To comply with legal requirements, such as a law, regulation, court order, or subpoena\n'
                  '• To protect the safety, rights, property, or security of Meta Travel International, the App, any third party, or the general public\n'
                  '• In connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business\n'
                  '• With your consent or at your direction\n\n'
                  'We do not sell your personal information to third parties.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Data Security',
                  'We implement appropriate technical and organizational measures to protect the information we collect and store. However, no security system is impenetrable, and we cannot guarantee the security of our systems 100%. In the event that any information under our control is compromised as a result of a breach of security, we will take reasonable steps to investigate the situation and, where appropriate, notify those individuals whose information may have been compromised.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Your Rights and Choices',
                  'You may update, correct, or delete your account information at any time by logging into your account or contacting us. You may also opt out of receiving promotional communications from us by following the instructions in those communications. Note that even if you opt out, we may still send you non-promotional communications, such as those about your account or our ongoing business relations.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Changes to this Privacy Policy',
                  'We may update this Privacy Policy from time to time. The updated version will be indicated by an updated "Last Updated" date and the updated version will be effective as soon as it is accessible. We encourage you to review this Privacy Policy frequently to be informed of how we are protecting your information.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 700.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    'Last updated: May 2025',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      // No bottom navigation bar for settings pages
    );
  }

  Widget _buildHeading(String text) {
    return Container(
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
        text,
        style: TextStyle(
          color: AppTheme.goldColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: EdgeInsets.only(top: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 8),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.goldColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, 
                    color: AppTheme.goldColor, size: 18),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
