import 'package:flutter/material.dart';

/// Utility function to combine multiple class names
String cn(List<String> classes) {
  return classes.where((c) => c.isNotEmpty).join(' ');
}

/// Extension method to easily apply opacity to colors
extension ColorExtension on Color {
  Color withOpacity(double opacity) {
    return Color.fromRGBO(
      red,
      green,
      blue,
      opacity,
    );
  }
}
