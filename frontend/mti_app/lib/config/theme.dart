import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFD4AF37); // Gold primary color
  static const Color accentColor = Color(0xFFE5A00D); // Amber accent
  static const Color tertiaryColor = Color(0xFFF5C242); // Light gold
  static const Color backgroundColor = Color(0xFF000000); // AMOLED Black
  static const Color secondaryBackgroundColor = Color(0xFF0A0A0A); // Slightly lighter black
  static const Color cardColor = Color(0xFF121212); // Material dark surface
  static const Color surfaceColor = Color(0xFF1E1E1E); // Slightly lighter surface
  
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color primaryTextColor = Color(0xFFFFFFFF); // Added primary text color
  static const Color secondaryTextColor = Color(0xFFB4B7C0);
  static const Color tertiaryTextColor = Color(0xFF8A8D98);
  
  static const Color successColor = Color(0xFF00C566);
  static const Color errorColor = Color(0xFFFF4A55);
  static const Color warningColor = Color(0xFFFFAD0D);
  static const Color infoColor = Color(0xFF00B2FF);
  static const Color goldColor = Color(0xFFD4AF37); // More sophisticated gold

  static const Color dividerColor = Color(0xFF2D3371);
  static const Color borderColor = Color(0xFF2D3371); // Added border color
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37), // Gold
      Color(0xFFE5A00D), // Amber
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF121212),
      Color(0xFF1E1E1E),
    ],
  );
  
  static const LinearGradient depositGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C566),
      Color(0xFF00A155),
    ],
  );
  
  static const LinearGradient withdrawGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF4A55),
      Color(0xFFE5323C),
    ],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37), // Sophisticated gold
      Color(0xFFAA8A25), // Deeper gold
    ],
  );
  
  // Luxury gradient with subtle shimmer effect
  static LinearGradient luxuryGradient({double opacity = 1.0}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFD4AF37).withOpacity(opacity), // Gold
        Color(0xFFE5A00D).withOpacity(opacity), // Amber
        Color(0xFFD4AF37).withOpacity(opacity), // Back to gold
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
        onPrimary: Colors.black, // Black text on gold
        secondary: accentColor,
        onSecondary: Colors.black, // Black text on amber
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
          foregroundColor: Colors.black, // Black text on gold buttons for better contrast
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // More pronounced elevation for luxury feel
          shadowColor: primaryColor.withOpacity(0.5), // Gold shadow
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
          borderSide: const BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A), width: 1),
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
