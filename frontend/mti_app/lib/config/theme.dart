import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF3B82F6); // Blue primary color
  static const Color accentColor = Color(0xFF60A5FA); // Light blue accent
  static const Color tertiaryColor = Color(0xFF93C5FD); // Lighter blue
  static const Color backgroundColor = Color(0xFF0F172A); // Dark blue background
  static const Color secondaryBackgroundColor = Color(0xFF1E293B); // Slightly lighter dark blue
  static const Color cardColor = Color(0xFF1E293B); // Card background color
  static const Color surfaceColor = Color(0xFF293548); // Surface color
  
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White text
  static const Color secondaryTextColor = Color(0xFFE2E8F0); // Slightly dimmed white
  static const Color tertiaryTextColor = Color(0xFF94A3B8); // Muted text
  
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  static const Color goldColor = Color(0xFFD4AF37); // Keep gold for accents/special elements

  static const Color dividerColor = Color(0xFF334155);
  static const Color borderColor = Color(0xFF334155);
  
  // Galaxy animation colors
  static const Color galaxyBlue1 = Color(0xFF1a237e); // Deep Blue
  static const Color galaxyBlue2 = Color(0xFF0d47a1); // Navy Blue
  static const Color galaxyPurple = Color(0xFF4a148c); // Deep Purple
  static const Color galaxyDarkBlue = Color(0xFF0a0f28); // Very Dark Blue almost black
  static const Color galaxyGold = Color(0xFFFFD700); // Gold
  static const Color galaxyStarColor = Color(0xFFE3F2FD); // Star color

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // Medium blue
      Color(0xFF2563EB), // Darker blue
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A), // Dark blue
      Color(0xFF0D1425), // Darker blue
    ],
  );
  
  // Premium galaxy gradient for backgrounds
  static const LinearGradient galaxyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      galaxyDarkBlue,
      galaxyBlue1,
      galaxyPurple,
      galaxyBlue2,
      galaxyDarkBlue,
    ],
    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
  );
  
  // Galaxy animation settings
  static const Duration galaxyAnimationDuration = Duration(seconds: 30);
  static const Duration starTwinkleDuration = Duration(seconds: 3);
  static const Duration nebulaMovementDuration = Duration(seconds: 60);
  static const double starsOpacity = 0.85;
  static const int starDensity = 100; // Number of stars per screen
  static const double nebulaOpacity = 0.15;
  
  static const LinearGradient depositGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Green
      Color(0xFF059669), // Darker green
    ],
  );
  
  static const LinearGradient withdrawGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444), // Red
      Color(0xFFDC2626), // Darker red
    ],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37), // Gold
      Color(0xFFAA8A25), // Darker gold
    ],
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // Blue
      Color(0xFF1D4ED8), // Darker blue
    ],
  );
  
  // Button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3B82F6), // Blue
      Color(0xFF60A5FA), // Lighter blue
    ],
  );
  
  // Luxury galaxy gradient with gold accent
  static LinearGradient luxuryGalaxyGradient({double opacity = 1.0}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        galaxyDarkBlue.withOpacity(opacity),
        galaxyBlue1.withOpacity(opacity * 0.8),
        galaxyPurple.withOpacity(opacity * 0.7),
        galaxyBlue2.withOpacity(opacity * 0.8),
        galaxyDarkBlue.withOpacity(opacity),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
  }
  
  // Luxury gradient with subtle shimmer effect
  static LinearGradient luxuryGradient({double opacity = 1.0}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF3B82F6).withOpacity(opacity), // Blue
        Color(0xFF60A5FA).withOpacity(opacity), // Lighter blue
        Color(0xFF3B82F6).withOpacity(opacity), // Back to blue
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: Colors.white, // White text on blue
        secondary: accentColor,
        onSecondary: Colors.white, // White text on light blue
        error: errorColor,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textColor,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textColor,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: textColor,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: textColor,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: textColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          color: secondaryTextColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
          color: textColor,
        ),
      ),
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // White text on blue buttons
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, 
          shadowColor: primaryColor.withOpacity(0.5), // Blue shadow
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: tertiaryTextColor,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: secondaryTextColor,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.inter(
          color: errorColor,
          fontSize: 12,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryBackgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: tertiaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
