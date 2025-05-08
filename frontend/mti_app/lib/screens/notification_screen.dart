import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../shared/widgets/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Current implementation preserved as comments for future use
  /*
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Referral Bonus',
      'message': 'You received 50 USDT from your referral Jane Smith.',
      'time': 'Just now',
      'isRead': false,
      'type': 'referral', // referral, system, transaction, promotion
    },
    {
      'title': 'Deposit Successful',
      'message': 'Your deposit of 1,000 USDT has been confirmed.',
      'time': '2 hours ago',
      'isRead': false,
      'type': 'transaction',
    },
    {
      'title': 'Limited Time Offer',
      'message': 'Get 10% extra on all deposits above 500 USDT until April 30.',
      'time': 'Yesterday',
      'isRead': true,
      'type': 'promotion',
    },
    {
      'title': 'System Maintenance',
      'message': 'Scheduled maintenance on April 25, 2025 from 2:00 AM to 4:00 AM UTC.',
      'time': '2 days ago',
      'isRead': true,
      'type': 'system',
    },
    {
      'title': 'Withdrawal Processed',
      'message': 'Your withdrawal of 500 USDT has been processed.',
      'time': '3 days ago',
      'isRead': true,
      'type': 'transaction',
    },
    {
      'title': 'New Travel Package',
      'message': 'Explore our new Bali luxury package with 15% discount for early birds.',
      'time': '5 days ago',
      'isRead': true,
      'type': 'promotion',
    },
  ];
  */
  
  // Empty list for coming soon implementation
  final List<Map<String, dynamic>> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // Actions removed for coming soon implementation
        /*
        actions: [
          IconButton(
            icon: const Icon(
              Icons.done_all,
              color: AppTheme.goldColor,
            ),
            onPressed: () {
              // Mark all as read
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: AppTheme.infoColor,
                ),
              );
            },
          ),
        ],
        */
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active,
              size: 80,
              color: Colors.amber[300],
            ),
            const SizedBox(height: 20),
            const Text(
              "Coming Soon",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Notification functionality will be available soon",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppTheme.tertiaryTextColor,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Notifications",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You don't have any notifications yet",
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification, index);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    // Define icon and color based on notification type
    IconData icon;
    Color color;
    
    switch (notification['type']) {
      case 'referral':
        icon = Icons.people_outline;
        color = AppTheme.primaryColor;
        break;
      case 'transaction':
        icon = Icons.account_balance_wallet_outlined;
        color = AppTheme.successColor;
        break;
      case 'promotion':
        icon = Icons.local_offer_outlined;
        color = AppTheme.goldColor;
        break;
      case 'system':
        icon = Icons.info_outline;
        color = AppTheme.infoColor;
        break;
      default:
        icon = Icons.notifications_none;
        color = AppTheme.accentColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification['isRead'] 
            ? AppTheme.secondaryBackgroundColor 
            : AppTheme.secondaryBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: notification['isRead'] 
            ? null 
            : Border.all(color: AppTheme.goldColor.withOpacity(0.3), width: 1),
        boxShadow: notification['isRead'] 
            ? null 
            : [
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Dismissible(
        key: Key('notification_${index}'),
        background: Container(
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            _notifications.removeAt(index);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification removed'),
              backgroundColor: AppTheme.infoColor,
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: notification['isRead'] ? FontWeight.w500 : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['message'],
                style: const TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                notification['time'],
                style: const TextStyle(
                  color: AppTheme.tertiaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: notification['isRead'] 
              ? null 
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            // Mark as read when tapped
            if (!notification['isRead']) {
              setState(() {
                notification['isRead'] = true;
              });
            }
            
            // Show notification details
            _showNotificationDetails(notification);
          },
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms, duration: 500.ms);
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          notification['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'],
              style: const TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppTheme.tertiaryTextColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  notification['time'],
                  style: const TextStyle(
                    color: AppTheme.tertiaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Close",
              style: TextStyle(
                color: AppTheme.goldColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
