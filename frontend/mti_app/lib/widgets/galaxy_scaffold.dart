import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import 'galaxy_background.dart';

/// A scaffold that uses the animated galaxy background throughout the app
class GalaxyScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final bool resizeToAvoidBottomInset;
  final double starDensity;
  final double nebulaOpacity;
  final bool showShootingStars;
  final PreferredSizeWidget? appBar;
  
  const GalaxyScaffold({
    Key? key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonLocation,
    this.drawer,
    this.resizeToAvoidBottomInset = true,
    this.starDensity = 1.0,
    this.nebulaOpacity = 0.15,
    this.showShootingStars = true,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar ?? (title != null 
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            title: Text(
              title!,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: actions,
          ) 
        : null),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: GalaxyBackground(
        starDensity: starDensity,
        nebulaOpacity: nebulaOpacity,
        showShootingStars: showShootingStars,
        child: body,
      ),
    );
  }
} 