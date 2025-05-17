import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../core/constants.dart';

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
    final spacing = level1Width / math.max(level1Nodes.length, 1);

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
    final nodeSpacing = size.width / math.max(level2Nodes.length, 1);
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

// Custom painter for angled connector lines
class AngleLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isLeftAlign;

  AngleLinePainter({
    required this.color,
    required this.strokeWidth,
    this.isLeftAlign = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Start from the center top
    path.moveTo(size.width / 2, 0);

    // Create angled path based on alignment (left or right)
    if (isLeftAlign) {
      // Angled to the left
      path.lineTo(size.width * 0.3, size.height * 0.5);
      path.lineTo(size.width * 0.5, size.height);
    } else {
      // Angled to the right
      path.lineTo(size.width * 0.7, size.height * 0.5);
      path.lineTo(size.width * 0.5, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AngleLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isLeftAlign != isLeftAlign;
  }
}

// Direct connecting line painter - draws a line from parent to child with an angle
class DirectConnectingLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Offset start;
  final Offset end;

  DirectConnectingLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.start,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Create a path with a gentle curve for a more organic feel
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // Control points for the curve
    final controlPoint1 = Offset(start.dx, start.dy + (end.dy - start.dy) * 0.4);
    final controlPoint2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.6);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DirectConnectingLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.start != start ||
        oldDelegate.end != end;
  }
}

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({Key? key}) : super(key: key);

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

// Star class for the starry night background
class Star {
  double x;
  double y;
  double size;
  double brightness;
  double blinkSpeed;
  
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.blinkSpeed,
  });
}

// Meteorite class for animations
class Meteorite {
  double startX;
  double startY;
  double endX;
  double endY;
  double progress;
  double speed;
  double size;
  double tailLength;
  bool isActive;
  
  Meteorite({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    this.progress = 0.0,
    required this.speed,
    required this.size,
    required this.tailLength,
    this.isActive = false,
  });
  
  void update(double deltaTime) {
    if (isActive) {
      progress += speed * deltaTime;
      if (progress >= 1.0) {
        progress = 0.0;
        isActive = false;
      }
    }
  }
  
  void activate() {
    isActive = true;
    progress = 0.0;
  }
}

// Custom painter for the starry night background
class StarryNightPainter extends CustomPainter {
  final List<Star> stars;
  final List<Meteorite> meteorites;
  final double animationValue;
  final bool isLowPerformanceMode;
  
  StarryNightPainter({
    required this.stars,
    required this.meteorites,
    required this.animationValue,
    this.isLowPerformanceMode = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Create a starry night background gradient
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.5),
        size.width,
        [
          Color(0xFF000510), // Very dark blue center
          Color(0xFF00081a), // Dark blue edges
        ],
      );
    
    // Paint for stars with more vivid appearance
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Draw stars with enhanced twinkling effect
    for (var star in stars) {
      // More complex twinkle with combined sine waves for natural effect
      final twinkle = (math.sin(animationValue * star.blinkSpeed) + 
                      math.sin(animationValue * star.blinkSpeed * 1.3 + 0.5)) / 3 + 0.7;
                      
      // Occasional color variation for some stars
      final colorVariation = (star.x + star.y) % 1.0 > 0.7;
      final starColor = colorVariation 
          ? Color.lerp(Colors.white, Colors.lightBlueAccent, 0.3)! 
          : Colors.white;
          
      final adjustedBrightness = isLowPerformanceMode ? 0.8 : star.brightness * twinkle;
      
      starPaint.color = starColor.withOpacity(adjustedBrightness);
      
      // Draw a glow effect for larger stars
      if (star.size > 2.0) {
        // Outer glow
        canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.size * 2.0 * twinkle,
          Paint()
            ..color = starColor.withOpacity(0.05)
            ..style = PaintingStyle.fill,
        );
        
        // Middle glow
        canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.size * 1.5 * twinkle,
          Paint()
            ..color = starColor.withOpacity(0.1)
            ..style = PaintingStyle.fill,
        );
      }
      
      // Main star
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * (isLowPerformanceMode ? 1.0 : (0.8 + twinkle * 0.4)),
        starPaint,
      );
    }
    
    // Only draw meteorites in normal performance mode
    if (!isLowPerformanceMode) {
      // Draw active meteorites
      for (var meteorite in meteorites) {
        if (meteorite.isActive) {
          final currentX = meteorite.startX + (meteorite.endX - meteorite.startX) * meteorite.progress;
          final currentY = meteorite.startY + (meteorite.endY - meteorite.startY) * meteorite.progress;
          
          // Create a brighter gradient for the tail
          final gradient = ui.Gradient.linear(
            Offset(currentX * size.width, currentY * size.height),
            Offset(
              (currentX - (meteorite.endX - meteorite.startX) * meteorite.tailLength * meteorite.progress) * size.width,
              (currentY - (meteorite.endY - meteorite.startY) * meteorite.tailLength * meteorite.progress) * size.height,
            ),
            [
              Colors.white,
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.0),
            ],
            [0.0, 0.1, 1.0],
          );
          
          // Draw a wider glow around the meteorite trail
          final glowPaint = Paint()
            ..shader = gradient
            ..style = PaintingStyle.stroke
            ..strokeWidth = meteorite.size * 6.0
            ..strokeCap = StrokeCap.round;
          
          final path = Path();
          path.moveTo(currentX * size.width, currentY * size.height);
          path.lineTo(
            (currentX - (meteorite.endX - meteorite.startX) * meteorite.tailLength * meteorite.progress) * size.width,
            (currentY - (meteorite.endY - meteorite.startY) * meteorite.tailLength * meteorite.progress) * size.height,
          );
          
          // Draw the glow effect first
          canvas.drawPath(path, glowPaint..color = Colors.white.withOpacity(0.1));
          
          // Draw the main trail
          final meteoritePaint = Paint()
            ..shader = gradient
            ..style = PaintingStyle.stroke
            ..strokeWidth = meteorite.size * 2.5
            ..strokeCap = StrokeCap.round;
            
          canvas.drawPath(path, meteoritePaint);
          
          // Draw meteorite head (brighter point)
          canvas.drawCircle(
            Offset(currentX * size.width, currentY * size.height),
            meteorite.size * 1.5,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(StarryNightPainter oldDelegate) {
    // Only repaint if animation value changed significantly to save performance
    return (animationValue - oldDelegate.animationValue).abs() > 0.01;
  }
}

class _NetworkScreenState extends State<NetworkScreen> with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  late TabController _tabController;
  String _referralCode = "";
  bool _isLoading = true;
  bool _isNetworkDataLoading = true;
  
  // Animation controllers for starry background
  late AnimationController _starsAnimationController;
  late AnimationController _meteorAnimationController;
  Timer? _meteorTimer;
  
  // Stars and meteorites for background
  List<Star> _stars = [];
  List<Meteorite> _meteorites = [];
  bool _isLowPerformanceMode = false;
  DateTime _lastFrameTime = DateTime.now();

  Map<String, dynamic> _networkData = {};
  Map<String, dynamic> _networkStats = {};

  // View type for network tab (list or hierarchy)
  bool _isHierarchyView = false; // Default to list view

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize stars animation controller
    _starsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Initialize meteor animation controller
    _meteorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_updateMeteors);
    
    // Generate stars (using relative coordinates for responsive sizing)
    _generateStarsAndMeteors();
    
    // Start periodic meteor shower (one meteor every 2-5 seconds)
    _startMeteorShowers();
    
    // Check if we should use low performance mode
    _checkPerformanceMode();

    // Load user's affiliate code
    _loadAffiliateCode();

    // Load network data
    _loadNetworkData();
  }
  
  // Generate stars and meteors for the background
  void _generateStarsAndMeteors() {
    // Generate 80-120 stars with random properties for more density
    final random = math.Random();
    final starCount = random.nextInt(41) + 80; // 80-120 stars
    
    _stars = List.generate(starCount, (_) {
      // Create stars with more variety in size and brightness
      return Star(
        x: random.nextDouble(), // Relative x position (0-1)
        y: random.nextDouble(), // Relative y position (0-1)
        size: random.nextDouble() * 2.0 + 0.5, // Size between 0.5-2.5
        brightness: random.nextDouble() * 0.7 + 0.3, // Brightness between 0.3-1.0
        blinkSpeed: random.nextDouble() * 5.0 + 0.5, // Blink speed between 0.5-5.5 (more variety)
      );
    });
    
    // Add some special brighter stars
    for (int i = 0; i < 15; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 1.0 + 2.0, // Larger size: 2.0-3.0
        brightness: random.nextDouble() * 0.2 + 0.8, // Very bright: 0.8-1.0
        blinkSpeed: random.nextDouble() * 2.0 + 0.5, // Slower blink for big stars
      ));
    }
    
    // Generate 15 potential meteorites (more for frequent shooting stars)
    _meteorites = List.generate(15, (_) {
      // Meteorites from various directions, mainly top to bottom
      final startX = random.nextDouble(); // Can start from anywhere horizontally
      final startY = random.nextDouble() * 0.3; // Start Y between 0-0.3 (top area)
      
      // More varied trajectories
      final endX = startX + (random.nextDouble() * 1.0 - 0.5); // Random direction
      final endY = startY + (random.nextDouble() * 0.5 + 0.3); // Always move downward
      
      return Meteorite(
        startX: startX,
        startY: startY,
        endX: endX,
        endY: endY,
        speed: random.nextDouble() * 1.2 + 0.4, // Speed between 0.4-1.6 (faster)
        size: random.nextDouble() * 1.5 + 1.0, // Size between 1.0-2.5 (larger)
        tailLength: random.nextDouble() * 0.3 + 0.2, // Tail length between 0.2-0.5 (longer)
      );
    });
  }
  
  // Start periodic meteor showers
  void _startMeteorShowers() {
    // Don't start meteor showers in low performance mode
    if (_isLowPerformanceMode) return;
    
    // More frequent checks for meteor showers
    _meteorTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _meteorAnimationController.value = 0;
      _meteorAnimationController.forward();
      
      // Higher chance to activate a meteor
      if (math.Random().nextDouble() < 0.15) { // 15% chance every 100ms
        _activateRandomMeteor();
      }
    });
  }
  
  // Activate a random meteor
  void _activateRandomMeteor() {
    final random = math.Random();
    final inactiveMeteorites = _meteorites.where((m) => !m.isActive).toList();
    
    if (inactiveMeteorites.isNotEmpty) {
      final meteor = inactiveMeteorites[random.nextInt(inactiveMeteorites.length)];
      meteor.activate();
      
      // Sometimes activate multiple meteorites for meteor shower effect
      if (random.nextDouble() < 0.3 && inactiveMeteorites.length > 1) {
        final delay = random.nextInt(300) + 100; // 100-400ms delay
        Future.delayed(Duration(milliseconds: delay), () {
          final remainingInactive = _meteorites.where((m) => !m.isActive).toList();
          if (remainingInactive.isNotEmpty) {
            final secondMeteor = remainingInactive[random.nextInt(remainingInactive.length)];
            secondMeteor.activate();
          }
        });
      }
    }
  }
  
  // Update meteorites on each animation frame
  void _updateMeteors() {
    if (_isLowPerformanceMode) return;
    
    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMilliseconds / 1000.0;
    _lastFrameTime = now;
    
    for (var meteor in _meteorites) {
      meteor.update(deltaTime);
    }
  }
  
  // Check if we should use low performance mode
  void _checkPerformanceMode() {

    _isLowPerformanceMode = false;

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
      developer.log('Web image URL created: $baseUrl/$cleanPath', name: 'Network');
      return '$baseUrl/$cleanPath';
    } else {
      // For mobile, prepend the base URL
      return '${AppConstants.baseUrl}/$cleanPath';
    }
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
          // Directly use the root node data from the updated API
          _networkData = networkResponse['data'] ?? {};
          
          // Get the total members and direct referrals from API's accurate calculation
          if (networkResponse.containsKey('total_members')) {
            _networkStats['total_members'] = networkResponse['total_members'];
          }
          
          if (networkResponse.containsKey('direct_referrals')) {
            _networkStats['direct_referrals'] = networkResponse['direct_referrals'];
          }
        });
        developer.log('Loaded network data successfully', name: 'Network');
      } else {
        developer.log('Failed to load network data: ${networkResponse['message']}', name: 'Network');
      }

      // Get accurate network summary instead of the old network stats
      final summaryResponse = await ApiService.getNetworkSummary();
      if (summaryResponse['status'] == 'success') {
        setState(() {
          _networkStats = summaryResponse['data'] ?? {};
          
          // Store the data in _networkStats to maintain compatibility with existing UI
          if (!_networkStats.containsKey('total_downlines') && _networkStats.containsKey('total_members')) {
            _networkStats['total_downlines'] = _networkStats['total_members'];
          }
          
          if (!_networkStats.containsKey('downline_counts') && _networkStats.containsKey('direct_referrals')) {
            _networkStats['downline_counts'] = {
              'level_1': _networkStats['direct_referrals'],
            };
          }
        });
        developer.log('Loaded network summary successfully: ${summaryResponse['data']}', name: 'Network');
      } else {
        developer.log('Failed to load network summary: ${summaryResponse['message']}', name: 'Network');
        
        // Fallback to old stats endpoint if summary fails
        final statsResponse = await ApiService.getNetworkStats();
        if (statsResponse['status'] == 'success') {
          setState(() {
            _networkStats = statsResponse['data'] ?? {};
          });
          developer.log('Loaded network stats successfully (fallback)', name: 'Network');
        } else {
          developer.log('Failed to load network stats: ${statsResponse['message']}', name: 'Network');
        }
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
    _starsAnimationController.dispose();
    _meteorAnimationController.dispose();
    _meteorTimer?.cancel();
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
      final String shareMessage = 'Join MTI Travel International Community using my referral code: $_referralCode\n\nSign up here: $referralLink';

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
    return RefreshIndicator(
      onRefresh: () async {
        await _loadAffiliateCode();
        await _loadNetworkData();
      },
      color: AppTheme.goldColor,
      backgroundColor: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message with animated gradient
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              
              // Enhanced referral card
              _buildEnhancedReferralCard(),
              const SizedBox(height: 30),
              
              // Network stats with improved design
              _buildEnhancedNetworkStats(),
              
              // Add extra space at bottom for better scrolling
              const SizedBox(height: 50),
            ],
          ),
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

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    String greeting;
    
    if (now.hour < 12) {
      greeting = "Good Morning";
    } else if (now.hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryBackgroundColor,
            Colors.black.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.goldColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data?['status'] != 'success') {
            return Row(
            children: [
              Container(
                  width: 60,
                  height: 60,
                decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.goldColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: AppTheme.goldColor,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "User",
                        style: TextStyle(
                  color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Level 0",
                        style: TextStyle(
                          color: AppTheme.goldColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          
          // Extract user data from the API response
          final userData = snapshot.data?['data']?['user'];
          final String? avatarUrl = snapshot.data?['data']?['avatar_url'];
          final String userName = userData?['full_name'] ?? 'User';
          final String level = userData?['level'] != null ? 'Level ${userData?['level']}' : 'Level 0';
          
          return Row(
            children: [
              // User avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldColor, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: avatarUrl != null && avatarUrl.isNotEmpty 
                    ? Image.network(
                        getFormattedImageUrl(avatarUrl),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.goldColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.person,
                              color: AppTheme.goldColor,
                              size: 30,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          color: AppTheme.goldColor,
                          size: 30,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              // Greeting and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: AppTheme.goldColor.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          level,
                          style: TextStyle(
                            color: AppTheme.goldColor,
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
          );
        },
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
      begin: 0.2,
      end: 0,
      duration: 600.ms,
      curve: Curves.easeOutQuad,
    );
  }
  
  // Enhanced referral card with better UI
  Widget _buildEnhancedReferralCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.goldColor,
            Color(0xFFD4AF37),
            Color(0xFFAA8C30),
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
      child: Padding(
        padding: const EdgeInsets.all(3.0), // Border width
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                  // Title and subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              const Text(
                        "Grow Your Network",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
                      const SizedBox(height: 4),
                      Text(
                        "Invite friends & earn rewards",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                ),
              ),
            ],
          ),
                  
                  // Animated icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: AppTheme.goldColor,
                      size: 24,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(), // Repeating animation
                  ).shimmer(
                    duration: 2.seconds,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              // Referral code section
          Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                        Text(
                          "Your Referral Code",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                Text(
                  _referralCode,
                  style: const TextStyle(
                    color: Colors.white,
                            fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                      ],
                  ),

                    // Copy button with animation
                    InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: _referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied to clipboard'),
                            backgroundColor: AppTheme.successColor,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.goldColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.copy,
                          color: AppTheme.goldColor,
                          size: 20,
                        ),
                      ).animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                      ).scaleXY(
                        begin: 1.0,
                        end: 1.1,
                        duration: 1.5.seconds,
                        curve: Curves.easeInOut,
                      ),
                ),
              ],
            ),
          ),
              const SizedBox(height: 24),
              
              // Enhanced Share button with luxury design
              GestureDetector(
                onTap: _shareReferralCode,
                child: Container(
            width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.goldColor.withOpacity(0.6),
                        AppTheme.goldColor,
                        AppTheme.goldColor.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
          ),
        ],
      ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Share My Referral Link",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .moveY(begin: 20, end: 0, duration: 600.ms, curve: Curves.easeOutQuad, delay: 300.ms)
                .shimmer(duration: 1800.ms, delay: 1000.ms, color: Colors.white.withOpacity(0.4)),
        ],
      ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(
      begin: 0.3,
      end: 0,
      duration: 800.ms,
      delay: 200.ms,
      curve: Curves.easeOutQuad,
    );
  }

  // Enhanced network stats with better visualization
  Widget _buildEnhancedNetworkStats() {
    // Calculate total members from network data
    int totalMembers = _networkStats['total_members'] ?? 0;
    int directReferrals = _networkStats['direct_referrals'] ?? 0;
    
    // Format the values for display
    final totalMembersDisplay = totalMembers > 0 ? totalMembers.toString() : "--";
    final directReferralsDisplay = directReferrals > 0 ? directReferrals.toString() : "--";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Network Overview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.analytics_outlined,
              color: AppTheme.goldColor,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Summary of your team's performance",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        
        // Main stats cards
        Row(
          children: [
            Expanded(
              child: _buildGradientStatCard(
                "Total Members",
                totalMembersDisplay,
                Icons.groups_outlined,
                [Color(0xFF2C82C9), Color(0xFF0A617D)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGradientStatCard(
                "Direct Referrals",
                directReferralsDisplay,
                Icons.person_add_outlined,
                [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGradientStatCard(
                "Team Growth",
                "Coming Soon",
                Icons.trending_up_outlined,
                [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGradientStatCard(
                "Commission Rate",
                "Coming Soon",
                Icons.account_balance_wallet_outlined,
                [Color(0xFFE67E22), Color(0xFFD35400)],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 800.ms);
  }
  
  // Gradient stat card with better design
  Widget _buildGradientStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5), // Border width
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                    color: colors[0],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
                style: TextStyle(
              color: Colors.white,
                  fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
        ),
      ),
    ).animate().shimmer(delay: 400.ms, duration: 1.5.seconds);
  }
  
    Widget _buildNetworkTab() {
    // Show loading indicator while network data is loading
    if (_isNetworkDataLoading) {
      return Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadAffiliateCode();
        await _loadNetworkData();
      },
      color: AppTheme.goldColor,
      backgroundColor: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network structure header
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.goldColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_tree_outlined,
                              color: AppTheme.goldColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Network Structure",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Network visualization - fixed height to ensure proper layout
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 300, // Fixed height
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildNetworkList(_getNetworkData()),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutQuad,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getNetworkData() {
    // Use real network data if available
    if (_networkData.isNotEmpty) {
      developer.log('Using network data from API', name: 'Network');
      
      // Ensure we're returning data with consistent types
      return _safeNetworkData(_networkData);
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

  // Helper method to ensure consistent data types in network data
  Map<String, dynamic> _safeNetworkData(Map<String, dynamic> data) {
    // Create a safe copy of the data
    final safeData = Map<String, dynamic>.from(data);
    
    // Ensure all child nodes have consistent data types
    if (safeData.containsKey('children') && safeData['children'] is List) {
      safeData['children'] = _processSafeChildren(safeData['children'] as List);
    } else {
      safeData['children'] = [];
    }
    
    return safeData;
  }
  
  // Process children recursively to ensure consistent types
  List<Map<String, dynamic>> _processSafeChildren(List children) {
    return children.map<Map<String, dynamic>>((child) {
      if (child is! Map<String, dynamic>) {
        return {'id': 'invalid', 'name': 'Invalid Data', 'children': []};
      }
      
      final safeChild = Map<String, dynamic>.from(child);
      
      // Process nested children
      if (safeChild.containsKey('children') && safeChild['children'] is List) {
        safeChild['children'] = _processSafeChildren(safeChild['children'] as List);
      } else {
        safeChild['children'] = [];
      }
      
      return safeChild;
    }).toList();
  }

  Widget _buildNetworkList(Map<String, dynamic> networkData) {
    // Build a hierarchical view similar to the image
    return Stack(
      children: [
        // Starry night background (fixed with Positioned.fill)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _starsAnimationController,
            builder: (context, child) {
              return RepaintBoundary(
                child: CustomPaint(
                  painter: StarryNightPainter(
                    stars: _stars,
                    meteorites: _meteorites,
                    animationValue: _starsAnimationController.value,
                    isLowPerformanceMode: _isLowPerformanceMode,
                  ),
                  size: Size.infinite, // Use Size.infinite instead
                ),
              );
            },
          ),
        ),
        
        // Container with network structure
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25), // More transparent to see stars
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.goldColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNetworkNode(
                      networkData['id'],
                      networkData['name'] ?? 'You',
                      0,
                      true, // isTrader
                      true, // isActive
                      true, // isRoot
                      networkData['children'] is List ? networkData['children'] : [],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // State to track which nodes are expanded (showing add user button)
  final Map<String, bool> _expandedNodes = {};
  
  // Helper method to build a network node
  Widget _buildNetworkNode(dynamic rawId, dynamic rawName, int level, bool isTrader, bool isActive, bool isRoot, List<dynamic> children) {
    // Ensure id and name are strings
    final String id = rawId is int ? rawId.toString() : (rawId as String? ?? 'N/A');
    final String name = rawName is int ? rawName.toString() : (rawName as String? ?? 'Unknown');
    
    // Check if this node is expanded
    final bool isExpanded = _expandedNodes[id] == true;
    
    // Colors and styling based on status and level
    final Color textColor = isActive ? Colors.white : Colors.grey.shade500;
    
    // Calculate left margin based on level for indentation
    // Level 0 starts from left, each subsequent level is indented more
    final double leftMargin = level * 30.0;
    
    // Enhanced styling with gradients for better visual hierarchy
    final BoxDecoration nodeDecoration;
    final EdgeInsets nodeMargin;
    
    if (isRoot) {
      // Root node (trader) gets a luxury gold gradient
      nodeDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFDAAA00), // Darker gold
            Color(0xFFFFC800), // Medium gold
            Color(0xFFB38700), // Rich gold
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      );
      nodeMargin = EdgeInsets.only(bottom: 25, left: leftMargin);
    } else {
      // Regular nodes get appropriate colors based on status
      final Color bgColor = isTrader ? Colors.amber.shade700 : 
                           (isActive ? Colors.grey.shade800 : Colors.grey.shade900);
      
      nodeDecoration = BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isActive ? Colors.grey.shade700 : Colors.grey.shade800,
          width: 1,
        ),
      );
      nodeMargin = EdgeInsets.only(top: 16, bottom: 6, left: leftMargin);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Node itself
        GestureDetector(
          onTap: () {
            // When a node is clicked, toggle expanded state to show/hide add user button
            setState(() {
              // Toggle this node's expanded state
              _expandedNodes[id] = !isExpanded;
              
              // If opening this node, close all others for cleaner UI
              if (!isExpanded) {
                for (var key in _expandedNodes.keys.toList()) {
                  if (key != id) {
                    _expandedNodes[key] = false;
                  }
                }
              }
            });
            
            developer.log('Node clicked: $name with affiliate code: $id', name: 'Network');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            margin: nodeMargin,
            decoration: nodeDecoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isRoot ? FontWeight.bold : FontWeight.w500,
                    fontSize: isRoot ? 18 : 15,
                    letterSpacing: isRoot ? 0.5 : 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                // Number with star based on level or trader status
                if (isTrader) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "5",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isRoot ? 12 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.star, 
                          color: Colors.white, 
                          size: isRoot ? 12 : 10,
                        ),
                      ],
                    ),
                  ),
                ] else if (level == 1) ...[
                  // 1 with star for level 1
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "1",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star, 
                          color: Colors.white, 
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ).animate()
           .fadeIn(duration: 400.ms, delay: Duration(milliseconds: level * 100))
           .slide(begin: Offset(0, 0.1), end: Offset.zero, duration: 400.ms, delay: Duration(milliseconds: level * 100)),
        ),
        
        // Add new user button - only appears when a node is clicked/expanded
        if (isExpanded) ...[
          GestureDetector(
            onTap: () {
              // Show confirmation modal before launching registration
              _showRegistrationConfirmation(id, name);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.only(top: 8, bottom: 16, left: leftMargin),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                  color: AppTheme.goldColor.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.goldColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add new user',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 300.ms, curve: Curves.easeOutBack),
        ],
        
                  // Recursively show children nodes
        if (children.isNotEmpty) ...[
          const SizedBox(height: 4), // Reduced spacing
          // Visual connector line
          Padding(
            padding: EdgeInsets.only(left: leftMargin),
            child: Container(
              width: 2,
              height: 12, // Shorter connector line
              color: AppTheme.goldColor.withOpacity(0.5), // More visible
            ),
          ),
          const SizedBox(height: 2), // Reduced spacing
          // Children nodes with proper spacing
          Padding(
            padding: const EdgeInsets.only(top: 4), // Reduced spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                
                // Add compact spacing between nodes
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < children.length - 1 ? 5 : 0 // Reduced bottom spacing
                  ),
                  child: _buildNetworkNode(
                    child['id'], // Pass raw ID value for handling in the function
                    child['name'], // Pass raw name value for handling in the function
                    level + 1,
                    child['is_trader'] == 1 || child['is_trader'] == true,
                    child['status'] == 'approved',
                    false, // not root
                    child['children'] is List ? child['children'] : [],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
  
  // Show confirmation modal before launching registration
  void _showRegistrationConfirmation(String affiliateCode, String userName) {
    // Log the actual affiliate code being used
    developer.log('Showing confirmation for affiliate code: $affiliateCode', name: 'Network');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
                border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header line
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Icon
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1,
                color: AppTheme.goldColor,
                size: 30,
              ),
            ),
            
            // Title
            Text(
              "Register New User",
              style: const TextStyle(
                            color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              "You are about to register a new user under $userName with the following referral code:",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Affiliate code display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.goldColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Referral Code",
              style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        affiliateCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: affiliateCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Referral code copied to clipboard"),
                              backgroundColor: AppTheme.successColor,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                            color: AppTheme.goldColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
                          child: const Icon(
                            Icons.copy,
                            color: AppTheme.goldColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Center(
              child: Text(
                          "Cancel",
                style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Proceed button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _launchRegistrationWithAffiliateCode(affiliateCode);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.goldColor.withOpacity(0.8),
                            AppTheme.goldColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Proceed",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) {
      developer.log('Modal closed', name: 'Network');
    });
  }
  
  // Launch registration page with affiliate code
  void _launchRegistrationWithAffiliateCode(String affiliateCode) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 16),
              const Text('Opening registration page...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.secondaryBackgroundColor,
        ),
      );
      
      // Construct the registration URL with the affiliate code
      final urlString = 'https://register.metatravel.ai/register?affiliate_code=$affiliateCode';
      
      developer.log(
        'Launching registration with affiliate code: $affiliateCode',
        name: 'Network',
      );
      developer.log('URL: $urlString', name: 'Network');
      
      // Launch the URL using url_launcher
      if (!await launch(
        urlString,
        forceSafariVC: false,
        forceWebView: false,
      )) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      developer.log('Error launching registration URL: $e', name: 'Network');
      
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open registration page. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build custom tab item with icon and text
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

// Back to top button widget that appears after scrolling
class BackToTopButton extends StatefulWidget {
  @override
  _BackToTopButtonState createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<BackToTopButton> {
  bool _visible = false;
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Listen to the nearest scrollable ancestor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollable = Scrollable.of(context);
      if (scrollable != null) {
        scrollable.position.addListener(_onScroll);
      }
    });
  }
  
  void _onScroll() {
    // Start or reset the timer when scrolling occurs
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
    
    // Hide button when actively scrolling
    if (_visible) {
      setState(() {
        _visible = false;
      });
    }
  }
  
  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: _visible 
        ? Animate(
            effects: [
              FadeEffect(duration: 400.ms),
              ScaleEffect(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.elasticOut),
            ],
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppTheme.goldColor.withOpacity(0.8),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
              onPressed: () {
                // Find the nearest scrollable and scroll to top
                final scrollable = Scrollable.of(context);
                if (scrollable != null) {
                  scrollable.position.animateTo(
                    0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutCubic,
                  );
                }
                
                // Hide the button after clicking
                setState(() {
                  _visible = false;
                });
              },
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}

// Helper to check if there are any children at a given level
bool _hasNextLevel(List<dynamic> rootLevelNodes, int targetLevel) {
  if (targetLevel <= 1) {
    return rootLevelNodes.isNotEmpty;
  }
  
  // For level 2, we check if any level 1 nodes have children
  if (targetLevel == 2) {
    return rootLevelNodes.any((node) => 
      (node['children'] as List?)?.isNotEmpty == true);
  }
  
  // For deeper levels (3+), we need to traverse the tree
  List<dynamic> currentLevelNodes = rootLevelNodes;
  int currentLevel = 1;
  
  while (currentLevel < targetLevel - 1 && currentLevelNodes.isNotEmpty) {
    List<dynamic> nextLevelNodes = [];
    
    // Collect all children from current level
    for (var node in currentLevelNodes) {
      final children = node['children'] as List? ?? [];
      if (children.isNotEmpty) {
        nextLevelNodes.addAll(children);
      }
    }
    
    // Move to next level
    currentLevelNodes = nextLevelNodes;
    currentLevel++;
  }
  
  // Check if we have any nodes at the current level that have children
  return currentLevelNodes.any((node) => 
    (node['children'] as List?)?.isNotEmpty == true);
}
