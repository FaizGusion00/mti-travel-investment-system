import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import 'dart:math';
import '../services/api_service.dart';
import 'dart:developer' as developer;

// Custom layout delegate for positioning root and level 1 nodes
class NetworkLayoutDelegate extends MultiChildLayoutDelegate {
  final Map<String, dynamic> rootNode;
  final List<dynamic> level1Nodes;

  NetworkLayoutDelegate(this.rootNode, this.level1Nodes);

  @override
  void performLayout(Size size) {
    // Position the root node at the top center
    final rootSize = layoutChild('root', BoxConstraints.loose(size));
    positionChild('root', Offset((size.width - rootSize.width) / 2, 0));

    // Calculate positions for level 1 nodes
    final levelHeight = 120.0; // Distance from root to level 1
    final level1Width = size.width * 0.8;
    final spacing = level1Width / max(level1Nodes.length, 1);

    // Position each level 1 node
    for (int i = 0; i < level1Nodes.length; i++) {
      final String nodeId = 'level1_$i';
      final nodeSize = layoutChild(nodeId, BoxConstraints.loose(size));

      // Calculate position with even spacing
      final nodeX = (size.width - level1Width) / 2 + i * spacing + (spacing - nodeSize.width) / 2;
      final nodeY = levelHeight;

      positionChild(nodeId, Offset(nodeX, nodeY));

      // Calculate line positions
      final rootCenterX = (size.width - rootSize.width) / 2 + rootSize.width / 2;
      final rootBottomY = rootSize.height;
      final level1NodeTopX = nodeX + nodeSize.width / 2;
      final level1NodeTopY = nodeY;

      // Layout and position connecting line
      final lineId = 'line_root_$i';
      final lineSize = layoutChild(lineId, BoxConstraints.loose(size));

      // Position the line at the center of the connection
      final centerX = (rootCenterX + level1NodeTopX) / 2;
      final centerY = (rootBottomY + level1NodeTopY) / 2;
      final lineX = centerX - lineSize.width / 2;
      final lineY = centerY - lineSize.height / 2;
      positionChild(lineId, Offset(lineX, lineY));
    }
  }

  @override
  bool shouldRelayout(NetworkLayoutDelegate oldDelegate) {
    return oldDelegate.rootNode != rootNode || oldDelegate.level1Nodes != level1Nodes;
  }
}

// Custom layout delegate for level 2 nodes
class Level2LayoutDelegate extends MultiChildLayoutDelegate {
  final List<dynamic> level2Nodes;
  final double totalWidth;

  Level2LayoutDelegate(this.level2Nodes, this.totalWidth);

  @override
  void performLayout(Size size) {
    // Parent node is assumed to be positioned above
    final parentCenterX = size.width / 2;
    final parentBottomY = 0.0; // Parent is at the top of this container

    // Calculate positions for each level 2 node
    final nodeSpacing = size.width / max(level2Nodes.length, 1);
    final nodeY = 70.0; // Distance from parent to level 2

    for (int i = 0; i < level2Nodes.length; i++) {
      final String nodeId = 'node_$i';
      final nodeSize = layoutChild(nodeId, BoxConstraints.loose(size));

      // Calculate position with even spacing
      final nodeX = i * nodeSpacing + (nodeSpacing - nodeSize.width) / 2;

      positionChild(nodeId, Offset(nodeX, nodeY));

      // Calculate endpoints for the line
      final level2NodeTopX = nodeX + nodeSize.width / 2;
      final level2NodeTopY = nodeY;

      // Layout and position connecting line
      final lineId = 'line_$i';
      final lineSize = layoutChild(lineId, BoxConstraints.loose(size));

      // Position the line at the center of the connection
      final centerX = (parentCenterX + level2NodeTopX) / 2;
      final centerY = (parentBottomY + level2NodeTopY) / 2;
      final lineX = centerX - lineSize.width / 2;
      final lineY = centerY - lineSize.height / 2;
      positionChild(lineId, Offset(lineX, lineY));
    }
  }

  @override
  bool shouldRelayout(Level2LayoutDelegate oldDelegate) {
    return oldDelegate.level2Nodes != level2Nodes ||
        oldDelegate.totalWidth != totalWidth;
  }
}

// Line painter to draw direct connecting lines
class LinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  LinePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Simple clean straight line for network connections
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw a vertical line from top to bottom
    final start = Offset(size.width / 2, 0);
    final end = Offset(size.width / 2, size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Class to store line data for the painter
class LinePainterData {
  final Offset start;
  final Offset end;

  LinePainterData({required this.start, required this.end});
}

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({Key? key}) : super(key: key);

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _referralCode = "";
  bool _isLoading = true;
  bool _isNetworkDataLoading = true;

  // Network data from API
  Map<String, dynamic> _networkData = {};
  Map<String, dynamic> _networkStats = {};

  // View type for network tab (list or hierarchy)
  bool _isHierarchyView = true; // Default to hierarchy view

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load user's affiliate code
    _loadAffiliateCode();

    // Load network data
    _loadNetworkData();
  }

  // Load user's affiliate code from profile
  Future<void> _loadAffiliateCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final affiliateCode = await ApiService.getUserAffiliateCode();
      if (affiliateCode != null && affiliateCode.isNotEmpty) {
        setState(() {
          _referralCode = affiliateCode;
          _isLoading = false;
        });
        developer.log('Loaded affiliate code: $_referralCode', name: 'Network');
      } else {
        setState(() {
          _referralCode = "N/A";
          _isLoading = false;
        });
        developer.log('No affiliate code found', name: 'Network');
      }
    } catch (e) {
      setState(() {
        _referralCode = "N/A";
        _isLoading = false;
      });
      developer.log('Error loading affiliate code: $e', name: 'Network');
    }
  }

  // Load network data from backend
  Future<void> _loadNetworkData() async {
    setState(() {
      _isNetworkDataLoading = true;
    });

    try {
      // Get network data (hierarchical structure)
      final networkResponse = await ApiService.getNetwork(levels: 5);
      if (networkResponse['status'] == 'success') {
        setState(() {
          _networkData = networkResponse['data'] ?? {};
        });
        developer.log('Loaded network data successfully', name: 'Network');
      } else {
        developer.log('Failed to load network data: ${networkResponse['message']}', name: 'Network');
      }

      // Get network statistics
      final statsResponse = await ApiService.getNetworkStats();
      if (statsResponse['status'] == 'success') {
        setState(() {
          _networkStats = statsResponse['data'] ?? {};
        });
        developer.log('Loaded network stats successfully', name: 'Network');
      } else {
        developer.log('Failed to load network stats: ${statsResponse['message']}', name: 'Network');
      }
    } catch (e) {
      developer.log('Error loading network data: $e', name: 'Network');
    } finally {
      setState(() {
        _isNetworkDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareReferralCode() async {
    // Don't try to share if code is not loaded yet
    if (_referralCode.isEmpty || _referralCode == "N/A") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Affiliate code not available yet. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Construct the link with the web registration page and affiliate_code parameter
      final String referralLink = 'https://register.metatravel.ai/register?affiliate_code=${_referralCode}';
      final String shareMessage = 'Join MTI Travel Investment using my referral code: $_referralCode\n\nSign up here: $referralLink';

      // First copy to clipboard as a backup
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

      // Log sharing action
      developer.log('Sharing referral link: $referralLink', name: 'Network');

      // Use share_plus to share the referral link
      await Share.share(
        shareMessage,
        subject: 'MTI Travel Investment Referral',
      );
    } catch (e) {
      developer.log('Error sharing referral code: $e', name: 'Network');

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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.goldColor))
              : Container(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.access_time_rounded,
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
            "Earnings functionality will be available soon",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
    // Original implementation preserved for future use
    /*
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
    */
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
            "Share your referral code now!",
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
    // Extract data from network stats or provide defaults
    final totalMembers = _networkStats.isEmpty ? "--" : (_networkStats['total_downlines'] ?? 0).toString();
    final directReferrals = _networkStats.isEmpty ? "--" : (_networkStats['direct_downlines'] ?? 0).toString();
    final teamVolume = "Coming Soon";
    final totalEarnings = "Coming Soon";

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
                totalMembers,
                Icons.people_outline,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Direct Referrals",
                directReferrals,
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
                teamVolume,
                Icons.bar_chart_outlined,
                AppTheme.tertiaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Total Earnings",
                totalEarnings,
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
    // Show loading indicator while network data is loading
    if (_isNetworkDataLoading) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.goldColor),
              const SizedBox(height: 16),
              Text(
                "Loading your network...",
                style: TextStyle(
                  color: AppTheme.goldColor.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View toggle header
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title with icon
                  const Text(
                    "Network Structure",
                    style: TextStyle(
                      color: AppTheme.goldColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // View toggle switch - more compact
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isHierarchyView = !_isHierarchyView;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.goldColor.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          // List View Toggle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isHierarchyView ? Colors.transparent : AppTheme.goldColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "List",
                              style: TextStyle(
                                color: _isHierarchyView ? Colors.grey : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(width: 4),

                          // Hierarchy View Toggle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isHierarchyView ? AppTheme.goldColor.withOpacity(0.7) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Tree",
                              style: TextStyle(
                                color: _isHierarchyView ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Network visualization - optimized for better scrolling
            SizedBox(
              height: MediaQuery.of(context).size.height - 200, // Give more vertical space
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.goldColor.withOpacity(0.15), width: 1),
                  ),
                  child: _isHierarchyView
                      ? _buildNetworkTree(_getNetworkData())
                      : _buildNetworkList(_getNetworkData()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getNetworkData() {
    // Use real network data if available
    if (_networkData.isNotEmpty) {
      developer.log('Using network data from API', name: 'Network');
      return _networkData;
    }

    // If no data, return minimal structure
    developer.log('No network data available', name: 'Network');
    return {
      'id': _referralCode.isEmpty ? 'N/A' : _referralCode,
      'name': 'You',
      'level': 'Level 0',
      'downlines': 0,
      'children': [], // Empty network when no data is available
    };
  }

  Widget _buildNetworkList(Map<String, dynamic> networkData) {
    // Extract all downlines and flatten into a single list
    List<Map<String, dynamic>> allMembers = [];

    // Add the root user (current user)
    allMembers.add({
      'id': networkData['id'] ?? '',
      'name': networkData['name'] ?? 'You',
      'level': 'Level 0',
      'joinDate': 'You',
      'status': 'Active',
      'isActive': true,
    });

    // Process all children (level 1)
    final children = networkData['children'] as List<dynamic>? ?? [];
    for (var child in children) {
      allMembers.add({
        'id': child['id'] ?? '',
        'name': child['name'] ?? '',
        'level': 'Level 1',
        'joinDate': child['joinDate'] ?? '',
        'status': child['status'] ?? 'Inactive',
        'isActive': child['isActive'] ?? false,
      });

      // Process all grandchildren (level 2)
      final grandchildren = child['children'] as List<dynamic>? ?? [];
      for (var grandchild in grandchildren) {
        allMembers.add({
          'id': grandchild['id'] ?? '',
          'name': grandchild['name'] ?? '',
          'level': 'Level 2',
          'joinDate': grandchild['joinDate'] ?? '',
          'status': grandchild['status'] ?? 'Inactive',
          'isActive': grandchild['isActive'] ?? false,
        });
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: allMembers.length,
      itemBuilder: (context, index) {
        final member = allMembers[index];
        final bool isRoot = index == 0;
        final bool isActive = member['isActive'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackgroundColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRoot ? AppTheme.goldColor : Colors.transparent,
              width: isRoot ? 1 : 0,
            ),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              member['name'] ?? '',
              style: TextStyle(
                color: Colors.white,
                fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "${member['level']} · ID: ${member['id']}",
              style: const TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 12,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkTree(Map<String, dynamic> rootNode) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Network Legend
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildColoredLegendItem(Colors.red, "You"),
                  const SizedBox(width: 16),
                  _buildColoredLegendItem(Colors.blue, "Level 1"),
                  const SizedBox(width: 16),
                  _buildColoredLegendItem(Colors.green, "Level 2"),
                  const SizedBox(width: 16),
                  _buildColoredLegendItem(Colors.grey, "Level 3"),
                ],
              ),
            ),

            // Network Tree
            Container(
              // Ensure enough height for scrolling
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: _buildCleanNetworkStructure(rootNode),
            ),

            // Add extra padding at the bottom for better scrolling
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanNetworkStructure(Map<String, dynamic> rootNode) {
    // If no children, show only the root node
    if (rootNode['children'] == null || (rootNode['children'] as List).isEmpty) {
      return Column(
        children: [
          _buildColoredNetworkNode(rootNode, isRoot: true, level: 0),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: const Text(
              "No downlines in your network yet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          // Add more padding for scrollable area even with no network
          const SizedBox(height: 200),
        ],
      );
    }

    // Get children nodes
    final List<dynamic> children = rootNode['children'] as List;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Root node (You) - Level 0
          _buildColoredNetworkNode(rootNode, isRoot: true, level: 0),

          // Render each branch with a connecting line
          for (int i = 0; i < children.length; i++)
            _buildNetworkBranch(children[i], i, children.length),

          // Add extra space after the network for scrolling
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  // Build a branch with connecting line
  Widget _buildNetworkBranch(Map<String, dynamic> node, int index, int totalNodes) {
    // Check if there are sub-children
    final List<dynamic> subChildren = node['children'] as List? ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Connecting line from parent
        Container(
          width: 2,
          height: 120, // Increased height for better spacing
          color: AppTheme.goldColor,
        ),

        // Level 1 node
        _buildColoredNetworkNode(node, isRoot: false, level: 1),

        // If this node has children, show them
        if (subChildren.isNotEmpty) ...[
          // Line connecting to sub-children
          Container(
            width: 2,
            height: 100, // Increased height for better spacing
            color: AppTheme.goldColor,
          ),

          // First sub-child
          _buildColoredNetworkNode(
            subChildren.first,
            isRoot: false,
            level: 2,
            isSmall: subChildren.length > 2,
          ),

          // Additional sub-children if more than one
          if (subChildren.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 20), // More padding for better view
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 1; i < min(4, subChildren.length); i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildColoredNetworkNode(
                        subChildren[i],
                        isRoot: false,
                        level: 2,
                        isSmall: true,
                      ),
                    ),
                ],
              ),
            ),
        ] else
        // If no children, add some spacing
          const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildColoredNetworkNode(Map<String, dynamic> node, {required bool isRoot, required int level, bool isSmall = false}) {
    final double cardSize = isRoot ? 70 : (isSmall ? 50 : 60);
    final bool isActive = node.containsKey('isActive') ? node['isActive'] : true;
    final String initials = (node['name'] ?? '').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final int downlines = node['downlines'] ?? 0;

    // Color coding based on level
    Color nodeColor;
    switch (level) {
      case 0:
        nodeColor = Colors.red; // Root (You)
        break;
      case 1:
        nodeColor = Colors.blue; // First level (B, C)
        break;
      case 2:
        nodeColor = Colors.green; // Second level (D, E, F, G)
        break;
      default:
        nodeColor = Colors.grey; // Any deeper levels
    }

    // Letter label based on position
    String? letterLabel;
    if (isRoot) {
      letterLabel = "A";
    } else if (level == 1) {
      // B and C for first level
      letterLabel = String.fromCharCode('B'.codeUnitAt(0) + (node['position'] as num? ?? 0).toInt());
    } else if (level == 2) {
      // D, E, F, G for second level
      letterLabel = String.fromCharCode('D'.codeUnitAt(0) + (node['position'] as num? ?? 0).toInt());
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _buildNodeDetailModal(node, isRoot, isActive, level: level),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Node avatar with color coding
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: cardSize,
                height: cardSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cardSize/2),
                  color: nodeColor.withOpacity(0.7),
                  border: Border.all(
                    color: nodeColor,
                    width: isRoot ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: nodeColor.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isRoot ? 22 : (isSmall ? 14 : 18),
                    ),
                  ),
                ),
              ),

              // Letter label at top left
              if (letterLabel != null)
                Positioned(
                  top: -5,
                  left: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      letterLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isRoot ? 12 : 10,
                      ),
                    ),
                  ),
                ),

              // Status indicator at bottom right
              if (!isRoot)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: isSmall ? 10 : 14,
                    height: isSmall ? 10 : 14,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),

          // Name and downline count
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            constraints: BoxConstraints(
              maxWidth: isSmall ? 90 : 100,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: nodeColor.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isRoot ? 12 : (isSmall ? 9 : 10),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (downlines > 0)
                  Text(
                    "$downlines",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isRoot ? 10 : (isSmall ? 8 : 9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modal for node details with color coding
  Widget _buildNodeDetailModal(Map<String, dynamic> node, bool isRoot, bool isActive, {int level = 0}) {
    final String initials = (node['name'] ?? '').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    // Color coding based on level
    Color nodeColor;
    switch (level) {
      case 0:
        nodeColor = Colors.red;
        break;
      case 1:
        nodeColor = Colors.blue;
        break;
      case 2:
        nodeColor = Colors.green;
        break;
      default:
        nodeColor = Colors.grey;
    }

    // Letter label based on position
    String? letterLabel;
    if (isRoot) {
      letterLabel = "A";
    } else if (level == 1) {
      letterLabel = String.fromCharCode('B'.codeUnitAt(0) + (node['position'] as num? ?? 0).toInt());
    } else if (level == 2) {
      letterLabel = String.fromCharCode('D'.codeUnitAt(0) + (node['position'] as num? ?? 0).toInt());
    }

    String levelName;
    switch (level) {
      case 0:
        levelName = "You";
        break;
      case 1:
        levelName = "Frontline";
        break;
      case 2:
        levelName = "Level 2";
        break;
      default:
        levelName = "Level ${level + 1}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: nodeColor.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info header
          Row(
            children: [
              // Avatar with coloring
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor.withOpacity(0.7),
                  border: Border.all(
                    color: nodeColor,
                    width: 2,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    if (letterLabel != null)
                      Positioned(
                        top: -5,
                        left: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: nodeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Text(
                            letterLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node['name'],
                      style: TextStyle(
                        color: nodeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: nodeColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          levelName,
                          style: TextStyle(
                            color: nodeColor.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.grey, height: 32, thickness: 0.5),

          // Stats section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUserStatItem("Status", isActive ? "Active" : "Inactive", isActive ? Colors.green : Colors.red),
              _buildUserStatItem("Downlines", "${node['downlines'] ?? 0}", nodeColor),
              if (node['joinDate'] != null)
                _buildUserStatItem("Joined", node['joinDate'], null),
            ],
          ),

          const SizedBox(height: 24),

          // ID section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ID: ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  node['id'] ?? '',
                  style: TextStyle(
                    color: nodeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for user stats with color
  Widget _buildUserStatItem(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Simple vertical connector - make it more visible
  Widget _buildVerticalConnector(double height) {
    return Container(
      width: 2,
      height: height,
      color: AppTheme.goldColor.withOpacity(0.6),
    );
  }

  // Colored legend item
  Widget _buildColoredLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
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
