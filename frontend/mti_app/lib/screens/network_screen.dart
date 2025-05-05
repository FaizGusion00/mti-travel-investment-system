import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import 'dart:math';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({Key? key}) : super(key: key);

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _referralCode = "MTI12345";
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareReferralCode() async {
    try {
      // First copy to clipboard as a backup
      final String referralLink = 'https://mti.travel/ref/${_referralCode}';
      final String shareMessage = 'Join MTI Travel Investment using my referral code: $_referralCode\n\nSign up here: $referralLink';
      
      await Clipboard.setData(ClipboardData(text: shareMessage));
      
      // Show loading indicator
      final loadingSnackBar = SnackBar(
        content: Row(
          children: [
            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            const SizedBox(width: 16),
            const Text('Opening share dialog...'),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.secondaryBackgroundColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);
      
      // Wait a moment before showing share dialog
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Use share_plus to share the referral link
      await Share.share(
        shareMessage,
        subject: 'MTI Travel Investment Referral',
      );
    } catch (e) {
      // Show success message for clipboard at least
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Referral link copied to clipboard. You can now paste and share it.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.infoColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Network",
          style: TextStyle(
            color: AppTheme.goldColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // Remove default divider
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 5),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackgroundColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.goldColor.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              // Remove default indicator
              indicatorColor: Colors.transparent,
              indicatorWeight: 0,
              dividerColor: Colors.transparent, // Remove the divider line
              labelColor: AppTheme.goldColor,
              unselectedLabelColor: AppTheme.secondaryTextColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.goldColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldColor.withOpacity(0.3), width: 1),
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(5),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                _buildCustomTab("My Team", Icons.people_outline),
                _buildCustomTab("Network", Icons.account_tree_outlined),
                _buildCustomTab("Earnings", Icons.account_balance_wallet_outlined),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeamTab(),
          _buildNetworkTab(),
          _buildEarningsTab(),
        ],
      ),

    );
  }

  Widget _buildTeamTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Smooth scrolling for Android
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReferralCard(),
            const SizedBox(height: 24),
            _buildNetworkStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Smooth scrolling for Android
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEarningsOverview(),
            const SizedBox(height: 24),
            _buildEarningsHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.goldColor,
            AppTheme.goldColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Invite Friends & Earn",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Share your referral code and earn 10% of your referrals' earnings",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _referralCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // Copy to clipboard using Flutter's Clipboard
                    await Clipboard.setData(ClipboardData(text: _referralCode));
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied to clipboard'),
                        backgroundColor: AppTheme.infoColor,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: "Share Referral Link",
            onPressed: _shareReferralCode,
            type: ButtonType.secondary,
            icon: Icons.share,
            width: double.infinity,
            isLoading: false,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
      begin: 0.1,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutQuad,
    );
  }

  Widget _buildNetworkStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Network Overview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Members",
                "--",
                Icons.people_outline,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Direct Referrals",
                "--",
                Icons.person_add_outlined,
                AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Team Volume",
                "----- USDT",
                Icons.bar_chart_outlined,
                AppTheme.tertiaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Total Earnings",
                "----- USDT",
                Icons.account_balance_wallet_outlined,
                AppTheme.infoColor,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stylish header with icon
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.goldColor.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(
                      Icons.account_tree_rounded,
                      color: AppTheme.goldColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Network Structure",
                    style: TextStyle(
                      color: AppTheme.goldColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Network visualization with scrolling capability
            SizedBox(
              height: MediaQuery.of(context).size.height - 220, // Fixed height with room for bottom nav
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.goldColor.withOpacity(0.15), width: 1),
                  ),
                  child: _buildNetworkTree(_getNetworkData()),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Map<String, dynamic> _getNetworkData() {
    // Network data structure with levels
    return {
      'id': 'MTI12345',
      'name': 'Faiz Gusion',
      'level': 'Level 0',
      'downlines': 8,
      'children': [
        {
          'id': 'MTI23456',
          'name': 'Jane Smith',
          'level': 'Level 1',
          'downlines': 3,
          'joinDate': 'Apr 10, 2025',
          'status': 'Active',
          'isActive': true,
          'children': [
            {
              'id': 'MTI34567',
              'name': 'Sarah Williams',
              'level': 'Level 2',
              'downlines': 0,
              'joinDate': 'Apr 5, 2025',
              'status': 'Inactive',
              'isActive': false,
              'children': [],
            },
            {
              'id': 'MTI45678',
              'name': 'Emily Davis',
              'level': 'Level 2',
              'downlines': 0,
              'joinDate': 'Mar 28, 2025',
              'status': 'Active',
              'isActive': true,
              'children': [],
            },
          ],
        },
        {
          'id': 'MTI56789',
          'name': 'Mike Johnson',
          'level': 'Level 1',
          'downlines': 2,
          'joinDate': 'Apr 8, 2025',
          'status': 'Active',
          'isActive': true,
          'children': [
            {
              'id': 'MTI67890',
              'name': 'David Wilson',
              'level': 'Level 2',
              'downlines': 0,
              'joinDate': 'Apr 3, 2025',
              'status': 'Active',
              'isActive': true,
              'children': [],
            },
            {
              'id': 'MTI78901',
              'name': 'Lisa Taylor',
              'level': 'Level 2',
              'downlines': 0,
              'joinDate': 'Mar 25, 2025',
              'status': 'Active',
              'isActive': true,
              'children': [],
            },
          ],
        },
        {
          'id': 'MTI89012',
          'name': 'Robert Brown',
          'level': 'Level 1',
          'downlines': 1,
          'joinDate': 'Apr 2, 2025',
          'status': 'Active',
          'isActive': true,
          'children': [
            {
              'id': 'MTI90123',
              'name': 'Jennifer Clark',
              'level': 'Level 2',
              'downlines': 0,
              'joinDate': 'Mar 20, 2025',
              'status': 'Active',
              'isActive': true,
              'children': [],
            },
          ],
        },
      ],
    };
  }

  Widget _buildNetworkTree(Map<String, dynamic> rootNode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for the tree
        final availableWidth = constraints.maxWidth;
        // Calculate the widest level based on root node's children
        double requiredWidth = 800.0; // Minimum width
        if (rootNode['children'] != null) {
          // Base width on deepest structure
          int maxChildCount = 0;
          for (var child in rootNode['children']) {
            if (child['children'] != null) {
              maxChildCount = max(maxChildCount, child['children'].length);
            }
          }
          // Estimate required width based on structure
          requiredWidth = max(rootNode['children'].length * 250.0, maxChildCount * 180.0 + 300);
        }
        
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              // Set minimum width to ensure scrolling works properly
              width: max(availableWidth, requiredWidth), // Dynamically calculated width
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status legend
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 30), // Increased spacing
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.goldColor.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLegendItem(Colors.green, "Active"),
                        const SizedBox(width: 32),
                        _buildLegendItem(Colors.red, "Inactive"),
                      ],
                    ),
                  ),
                  
                  // Root node
                  _buildNetworkNode(rootNode, isRoot: true),
                  const SizedBox(height: 30), // Increased spacing
                  
                  // Connect to first level
                  if (rootNode['children'].isNotEmpty) ...[
                    _buildVerticalConnector(60), // Longer connector
                    _buildFirstLevel(rootNode['children']),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // Build first level of nodes
  Widget _buildFirstLevel(List<dynamic> nodes) {
    // Calculate appropriate width based on number of nodes
    final double levelWidth = max(nodes.length * 250.0, 700.0); // Increase width per node
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal connecting line
        Container(
          width: levelWidth - 80, // Width based on number of nodes with more margin
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.goldColor.withOpacity(0.5),
                AppTheme.goldColor.withOpacity(0.8),
                AppTheme.goldColor.withOpacity(0.5),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // First level nodes row
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var node in nodes) 
              SizedBox(
                width: levelWidth / nodes.length, // Evenly distribute width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildVerticalConnector(30),
                    _buildNetworkNode(node, isRoot: false),
                    
                    // If has children, build second level
                    if (node['children'] != null && node['children'].isNotEmpty) ...[
                      const SizedBox(height: 30),
                      _buildVerticalConnector(40),
                      _buildSecondLevel(node['children']),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Build second level of nodes
  Widget _buildSecondLevel(List<dynamic> nodes) {
    // Calculate width based on number of children
    final double childWidth = max(nodes.length * 160.0, 320.0); // Increased width per node
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal connecting line
        Container(
          width: childWidth - 20,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.goldColor.withOpacity(0.3),
                AppTheme.goldColor.withOpacity(0.6),
                AppTheme.goldColor.withOpacity(0.3),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Second level nodes row with more spacing
        SizedBox(
          width: childWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var node in nodes) 
                SizedBox(
                  width: (childWidth / nodes.length) - 10, // Reduce width to add margin
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildVerticalConnector(30),
                      _buildNetworkNode(node, isRoot: false, isSmall: true),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Build network node with consistent sizing and better text handling
  Widget _buildNetworkNode(Map<String, dynamic> node, {required bool isRoot, bool isSmall = false}) {
    final double cardSize = isRoot ? 110 : (isSmall ? 85 : 95);
    final bool isActive = node.containsKey('isActive') ? node['isActive'] : true;
    final Color glowColor = isRoot 
        ? AppTheme.goldColor 
        : (isActive ? Colors.green : Colors.red);
    final String initials = node['name'].split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _buildNodeDetailModal(node, isRoot, isActive),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: isSmall ? 140 : 155,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glassmorphism card with avatar/initials
            Container(
              width: cardSize,
              height: cardSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardSize/2),
                color: Colors.white.withOpacity(0.13),
                border: Border.all(
                  color: isRoot ? AppTheme.goldColor : (isActive ? Colors.green : Colors.red),
                  width: isRoot ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(isRoot ? 0.32 : 0.18),
                    blurRadius: isRoot ? 18 : 10,
                    spreadRadius: 1,
                  ),
                ],
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: (cardSize / 2) - 10,
                      backgroundColor: Colors.black.withOpacity(0.7),
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: isRoot ? AppTheme.goldColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isRoot ? 28 : 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Status indicator (only for non-root nodes)
                  if (!isRoot)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: (isActive ? Colors.green : Colors.red).withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Crown/star for root
                  if (isRoot)
                    Positioned(
                      top: -8,
                      left: cardSize/2 - 16,
                      child: Icon(Icons.emoji_events, color: AppTheme.goldColor, size: 28, shadows: [Shadow(color: Colors.black26, blurRadius: 6)]),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.92, 0.92), end: Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack),
            // Name and downline count
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
              constraints: BoxConstraints(
                maxWidth: isSmall ? 130 : 140,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.82),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRoot ? AppTheme.goldColor.withOpacity(0.5) : (isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    node['name'],
                    style: TextStyle(
                      color: isRoot ? AppTheme.goldColor : Colors.white,
                      fontSize: isRoot ? 15 : (isSmall ? 12 : 13),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${node['downlines']} Downlines",
                    style: TextStyle(
                      color: isRoot ? AppTheme.goldColor : AppTheme.goldColor.withOpacity(0.7),
                      fontSize: isRoot ? 12 : (isSmall ? 10 : 11),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal for node details
  Widget _buildNodeDetailModal(Map<String, dynamic> node, bool isRoot, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.goldColor.withOpacity(0.15), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.13),
              border: Border.all(
                color: isRoot ? AppTheme.goldColor : (isActive ? Colors.green : Colors.red),
                width: isRoot ? 2.5 : 1.5,
              ),
            ),
            child: Center(
              child: Text(
                node['name'].split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                style: TextStyle(
                  color: isRoot ? AppTheme.goldColor : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            node['name'],
            style: TextStyle(
              color: isRoot ? AppTheme.goldColor : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            node['level'] ?? '',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Downlines: ${node['downlines']}",
            style: TextStyle(
              color: AppTheme.goldColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (node['joinDate'] != null) ...[
            const SizedBox(height: 8),
            Text(
              "Joined: ${node['joinDate']}",
              style: TextStyle(
                color: AppTheme.tertiaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
          if (node['status'] != null) ...[
            const SizedBox(height: 8),
            Text(
              "Status: ${node['status']}",
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build vertical connector with gold gradient and animation
  Widget _buildVerticalConnector(double height) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.goldColor.withOpacity(0.9),
            AppTheme.goldColor.withOpacity(0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.12, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCustomTab(String text, IconData icon) {
    return Tab(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Earnings Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Earnings",
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "2,458 USDT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "+12.5%",
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _EarningCategory(
                title: "Direct",
                amount: "1,245 USDT",
                percentage: 50,
                color: AppTheme.primaryColor,
              ),
              _EarningCategory(
                title: "Level 1",
                amount: "738 USDT",
                percentage: 30,
                color: AppTheme.accentColor,
              ),
              _EarningCategory(
                title: "Level 2",
                amount: "475 USDT",
                percentage: 20,
                color: AppTheme.tertiaryColor,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
      begin: 0.1,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutQuad,
    );
  }

  Widget _buildEarningsHistory() {
    final List<Map<String, dynamic>> earnings = [
      {
        'name': 'Jane Smith',
        'amount': '+125 USDT',
        'date': 'Apr 22, 2025',
        'type': 'Direct Referral',
        'icon': Icons.person_add_outlined,
        'color': AppTheme.primaryColor,
      },
      {
        'name': 'Mike Johnson',
        'amount': '+45 USDT',
        'date': 'Apr 20, 2025',
        'type': 'Level 1 Reward',
        'icon': Icons.people_outline,
        'color': AppTheme.accentColor,
      },
      {
        'name': 'Sarah Williams',
        'amount': '+18 USDT',
        'date': 'Apr 18, 2025',
        'type': 'Level 2 Reward',
        'icon': Icons.groups_outlined,
        'color': AppTheme.tertiaryColor,
      },
      {
        'name': 'Robert Brown',
        'amount': '+95 USDT',
        'date': 'Apr 15, 2025',
        'type': 'Direct Referral',
        'icon': Icons.person_add_outlined,
        'color': AppTheme.primaryColor,
      },
      {
        'name': 'Emily Davis',
        'amount': '+32 USDT',
        'date': 'Apr 12, 2025',
        'type': 'Level 1 Reward',
        'icon': Icons.people_outline,
        'color': AppTheme.accentColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Earnings History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View All",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: earnings.length,
          itemBuilder: (context, index) {
            final earning = earnings[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: earning['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      earning['icon'],
                      color: earning['color'],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          earning['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          earning['type'],
                          style: const TextStyle(
                            color: AppTheme.tertiaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        earning['amount'],
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        earning['date'],
                        style: const TextStyle(
                          color: AppTheme.tertiaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  // Enhanced legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.white, width: 1.2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _EarningCategory extends StatelessWidget {
  final String title;
  final String amount;
  final int percentage;
  final Color color;

  const _EarningCategory({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "$percentage%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
