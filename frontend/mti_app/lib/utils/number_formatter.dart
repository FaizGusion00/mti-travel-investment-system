import 'package:intl/intl.dart';

class NumberFormatter {
  /// Formats a number with commas as thousands separators
  /// Example: 1000 -> 1,000
  static String formatWithCommas(dynamic value) {
    if (value == null) return '0';
    
    // Convert to double first
    double numValue;
    if (value is String) {
      numValue = double.tryParse(value) ?? 0;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is double) {
      numValue = value;
    } else {
      return '0';
    }
    
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(numValue);
  }
  
  /// Formats a currency value with commas and 2 decimal places
  /// Example: 1000 -> 1,000.00
  static String formatCurrency(dynamic value) {
    if (value == null) return '0.00';
    
    // Convert to double first
    double numValue;
    if (value is String) {
      numValue = double.tryParse(value) ?? 0;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is double) {
      numValue = value;
    } else {
      return '0.00';
    }
    
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(numValue);
  }
}
