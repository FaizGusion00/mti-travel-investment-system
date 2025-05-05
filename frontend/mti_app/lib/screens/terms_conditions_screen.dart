import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../shared/widgets/bottom_nav_bar.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
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
                _buildHeading('MTI Travel Investment Terms & Conditions')
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 20),
                _buildSection(
                  'Acceptance of Terms',
                  'By accessing and using the MTI Travel Investment application ("App"), you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, you may not use our App.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Account Registration',
                  'To use certain features of the App, you must register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. You are responsible for safeguarding your account credentials and for all activities that occur under your account.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Investment Risks',
                  'All investments involve risk, and the past performance of a security, industry, sector, market, or financial product does not guarantee future results. MTI Travel Investment does not provide financial advice, and the information provided in the App should not be considered as such. Always conduct your own research and consider seeking advice from an independent financial advisor.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'User Conduct',
                  'You agree not to use the App for any unlawful purpose or in any way that could damage, disable, overburden, or impair the App. You further agree not to attempt to gain unauthorized access to any part of the App, other user accounts, or computer systems or networks connected to the App.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Intellectual Property',
                  'The App and its original content, features, and functionality are owned by MTI Travel Investment and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws. You may not reproduce, distribute, modify, create derivative works of, publicly display, publicly perform, republish, download, store, or transmit any of the material on our App.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Limitation of Liability',
                  'In no event shall MTI Travel Investment, its directors, employees, partners, agents, suppliers, or affiliates be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or other intangible losses, resulting from your access to or use of or inability to access or use the App.',
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                _buildSection(
                  'Changes to Terms',
                  'MTI Travel Investment reserves the right to modify or replace these Terms & Conditions at any time. It is your responsibility to review these Terms & Conditions periodically for changes. Your continued use of the App following the posting of any changes constitutes acceptance of those changes.',
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
                Icon(Icons.description_outlined, 
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
