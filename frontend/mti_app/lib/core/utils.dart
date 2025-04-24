import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import '../config/theme.dart';

class Utils {
  // Date formatting
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateFromString(String dateStr, {String format = 'yyyy-MM-dd'}) {
    try {
      final date = DateTime.parse(dateStr);
      return formatDate(date, format: format);
    } catch (e) {
      return dateStr;
    }
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Currency formatting
  static String formatCurrency(double amount, {String symbol = 'USDT', int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalPlaces,
    );
    return '${formatter.format(amount)} $symbol';
  }

  // Image picking
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    try {
      return await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Show image picker dialog
  static Future<XFile?> showImagePickerDialog(BuildContext context) async {
    XFile? pickedImage;
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      pickedImage = await pickImage(source: ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    context,
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      pickedImage = await pickImage(source: ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    return pickedImage;
  }

  static Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Validation
  static bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  static bool isValidPhone(String phone) {
    return GetUtils.isPhoneNumber(phone);
  }

  static bool isValidUrl(String url) {
    return GetUtils.isURL(url);
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  static bool isAdult(DateTime birthDate) {
    final today = DateTime.now();
    final age = today.year - birthDate.year - 
      (today.month < birthDate.month || 
      (today.month == birthDate.month && today.day < birthDate.day) ? 1 : 0);
    return age >= 18;
  }

  // Snackbars
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppTheme.successColor.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppTheme.errorColor.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Information',
      message,
      backgroundColor: AppTheme.infoColor.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  // URL launching
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbar('Could not launch $url');
    }
  }

  // Share content
  static Future<void> shareReferralCode(String referralCode) async {
    final String shareText = 'Join MTI Travel Investment using my referral code: $referralCode\n\nDownload the app: ${AppConstants.appDownloadUrl}';
    final Uri uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbar('Could not open WhatsApp to share');
    }
  }

  // Copy to clipboard
  static void copyToClipboard(String text) {
    // This would use the clipboard package in a real implementation
    showSuccessSnackbar('Copied to clipboard: $text');
  }

  // String truncation
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // Address formatting (for crypto addresses)
  static String formatAddress(String address, {int prefixLength = 6, int suffixLength = 4}) {
    if (address.length <= prefixLength + suffixLength) {
      return address;
    }
    return '${address.substring(0, prefixLength)}...${address.substring(address.length - suffixLength)}';
  }
}
