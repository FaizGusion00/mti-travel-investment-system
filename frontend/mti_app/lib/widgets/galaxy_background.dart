import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class GalaxyBackground extends StatefulWidget {
  final Widget? child;
  final double starDensity;
  final double nebulaOpacity;
  final bool showShootingStars;

  const GalaxyBackground({
    Key? key,
    this.child,
    this.starDensity = 1.0,
    this.nebulaOpacity = 0.15,
    this.showShootingStars = true,
  }) : super(key: key);

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<StarParticle> _stars;
  late List<NebulaCloud> _nebulaClouds;
  final Random _random = Random();
  late List<ShootingStar> _shootingStars;
  int _lastShootingStarTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.galaxyAnimationDuration,
    )..repeat(reverse: false);

    // Initialize stars
    _stars = List.generate(
      (AppTheme.starDensity * widget.starDensity).round(),
      (index) => StarParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 0.5,
        twinkleFactor: _random.nextDouble(),
        twinkleSpeed: _random.nextDouble() * 0.8 + 0.5,
        color: _getStarColor(_random.nextDouble()),
      ),
    );

    // Initialize nebula clouds
    _nebulaClouds = List.generate(
      5, // Number of nebula clouds
      (index) => NebulaCloud(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 0.6 + 0.4, // 0.4 to 1.0
        rotation: _random.nextDouble() * 2 * math.pi,
        color: _getNebulaColor(_random.nextDouble()),
        speed: _random.nextDouble() * 0.02 + 0.005, // Slow movement
      ),
    );

    // Initialize shooting stars (empty at first)
    _shootingStars = [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStarColor(double value) {
    if (value < 0.1) {
      return Colors.amber.withOpacity(0.85); // Gold-ish stars (rare)
    } else if (value < 0.3) {
      return Colors.blue[100]!.withOpacity(0.85); // Bluish stars
    } else {
      return AppTheme.galaxyStarColor.withOpacity(0.85); // White stars (common)
    }
  }

  Color _getNebulaColor(double value) {
    if (value < 0.2) {
      return AppTheme.galaxyPurple.withOpacity(widget.nebulaOpacity); // Purple nebula
    } else if (value < 0.5) {
      return AppTheme.galaxyBlue1.withOpacity(widget.nebulaOpacity); // Blue nebula
    } else if (value < 0.8) {
      return AppTheme.galaxyBlue2.withOpacity(widget.nebulaOpacity); // Navy blue nebula
    } else {
      // Very rare gold nebula
      return AppTheme.galaxyGold.withOpacity(widget.nebulaOpacity * 0.3); // Gold nebula (subtle)
    }
  }

  void _maybeAddShootingStar(Size size) {
    if (!widget.showShootingStars) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastShootingStarTime > 6000 && _random.nextDouble() < 0.1) { // 10% chance every 6 seconds
      _lastShootingStarTime = now;
      
      // Starting points are at the edges of the screen (top or right edge)
      final startAtTop = _random.nextBool();
      double startX, startY, endX, endY;
      
      if (startAtTop) {
        startX = _random.nextDouble() * size.width;
        startY = 0;
        endX = startX + (_random.nextDouble() * 1.2 - 0.6) * size.width;
        endY = size.height * (_random.nextDouble() * 0.6 + 0.3);
      } else {
        startX = size.width;
        startY = _random.nextDouble() * size.height * 0.5;
        endX = size.width * _random.nextDouble() * 0.5;
        endY = startY + (_random.nextDouble() * 1.2 - 0.3) * size.height * 0.5;
      }
      
      _shootingStars.add(ShootingStar(
        startX: startX / size.width,
        startY: startY / size.height,
        endX: endX / size.width,
        endY: endY / size.height,
        thickness: _random.nextDouble() * 1.5 + 0.5,
        speed: _random.nextDouble() * 1.5 + 1.5, // Speed in seconds
        creationTime: now,
      ));
      
      // Clean up old shooting stars
      _shootingStars = _shootingStars.where((star) {
        return now - star.creationTime < (star.speed * 1000 + 500);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.luxuryGalaxyGradient(),
          ),
          child: Stack(
            children: [
              // Animated nebula clouds
              CustomPaint(
                painter: NebulaPainter(
                  clouds: _nebulaClouds,
                  animationValue: _controller.value,
                ),
                size: Size.infinite,
              ),
              
              // Stars layer with twinkle effect
              LayoutBuilder(
                builder: (context, constraints) {
                  _maybeAddShootingStar(constraints.biggest);
                  return CustomPaint(
                    painter: StarfieldPainter(
                      stars: _stars,
                      animationValue: _controller.value,
                      shootingStars: _shootingStars,
                      now: DateTime.now().millisecondsSinceEpoch,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
              
              // Subtle radial gradient overlay for depth
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      AppTheme.galaxyDarkBlue.withOpacity(0.25),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              
              // Gold accent at bottom (very subtle)
              Positioned(
                bottom: -100,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, 1.0),
                      radius: 1.0,
                      colors: [
                        AppTheme.galaxyGold.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
              ),
              
              // Child content
              if (child != null) child,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

// A star in the galaxy
class StarParticle {
  final double x;
  final double y;
  final double size;
  final double twinkleFactor;
  final double twinkleSpeed;
  final Color color;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleFactor,
    required this.twinkleSpeed,
    required this.color,
  });

  double getOpacity(double animationValue) {
    // Create a smooth sine wave for twinkling
    final twinkleOffset = twinkleFactor * 2 * math.pi;
    final wave = math.sin((animationValue * twinkleSpeed * 2 * math.pi) + twinkleOffset);
    
    // Map the wave to an opacity between 0.3 and 1.0
    return 0.3 + (0.7 * (wave * 0.5 + 0.5));
  }
}

// A nebula cloud in the galaxy
class NebulaCloud {
  final double x;
  final double y;
  final double size;
  final double rotation;
  final Color color;
  final double speed;

  NebulaCloud({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.color,
    required this.speed,
  });

  Offset getPosition(double animationValue, Size canvasSize) {
    // Create a smooth circular/elliptical movement
    final angle = (animationValue * speed * 2 * math.pi) + (rotation);
    final offsetX = math.sin(angle) * 0.05;
    final offsetY = math.cos(angle) * 0.05;
    
    return Offset(
      (x + offsetX) * canvasSize.width,
      (y + offsetY) * canvasSize.height,
    );
  }
}

// A shooting star effect
class ShootingStar {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double thickness;
  final double speed; // in seconds
  final int creationTime; // milliseconds since epoch

  ShootingStar({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.thickness,
    required this.speed,
    required this.creationTime,
  });
  
  // Returns progress from 0 to 1
  double getProgress(int now) {
    final elapsed = (now - creationTime) / 1000; // in seconds
    return (elapsed / speed).clamp(0.0, 1.0);
  }
}

// CustomPainter for stars and shooting stars
class StarfieldPainter extends CustomPainter {
  final List<StarParticle> stars;
  final double animationValue;
  final List<ShootingStar> shootingStars;
  final int now;

  StarfieldPainter({
    required this.stars,
    required this.animationValue,
    required this.shootingStars,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint stars
    for (final star in stars) {
      final opacity = star.getOpacity(animationValue);
      final paint = Paint()
        ..color = star.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(
        star.x * size.width,
        star.y * size.height,
      );

      canvas.drawCircle(position, star.size, paint);
      
      // Add a subtle glow to larger stars
      if (star.size > 1.3) {
        final glowPaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          
        canvas.drawCircle(position, star.size * 2, glowPaint);
      }
    }
    
    // Paint shooting stars
    for (final star in shootingStars) {
      final progress = star.getProgress(now);
      
      if (progress >= 1.0) continue;
      
      // Determine current position
      final currentX = star.startX + (star.endX - star.startX) * progress;
      final currentY = star.startY + (star.endY - star.startY) * progress;
      
      // Path for the shooting star
      final path = Path();
      path.moveTo(
        currentX * size.width,
        currentY * size.height,
      );
      
      // Calculate trail length based on progress
      // Start small, grow, then shrink at the end
      final trailProgress = progress < 0.2 
          ? progress / 0.2 
          : (progress > 0.8 ? (1.0 - progress) / 0.2 : 1.0);
      
      final trailLengthFactor = 0.08 * trailProgress; // 8% of screen at max
      
      // Trail points back toward start
      final trailX = currentX - (star.endX - star.startX) * trailLengthFactor;
      final trailY = currentY - (star.endY - star.startY) * trailLengthFactor;
      
      path.lineTo(
        trailX * size.width,
        trailY * size.height,
      );
      
      // Gradient for the trail
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = star.thickness
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromPoints(
          Offset(currentX * size.width, currentY * size.height),
          Offset(trailX * size.width, trailY * size.height),
        ));
      
      canvas.drawPath(path, paint);
      
      // Add glow effect
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = star.thickness * 3
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromPoints(
          Offset(currentX * size.width, currentY * size.height),
          Offset(trailX * size.width, trailY * size.height),
        ))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.now != now;
  }
}

// CustomPainter for nebula clouds
class NebulaPainter extends CustomPainter {
  final List<NebulaCloud> clouds;
  final double animationValue;

  NebulaPainter({required this.clouds, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final cloud in clouds) {
      final center = cloud.getPosition(animationValue, size);
      final cloudRadius = cloud.size * math.min(size.width, size.height) * 0.4;
      
      // Create a radial gradient for the nebula
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            cloud.color,
            cloud.color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(
          center: center,
          radius: cloudRadius,
        ))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(center, cloudRadius, paint);
    }
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
} 