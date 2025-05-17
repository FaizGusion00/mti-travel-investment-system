// This file is used only when running in a web browser

import 'dart:html' as html;

import 'environment.dart';

// Extension to implement web-specific methods for BrowserWebStorage
extension BrowserWebStorageImpl on BrowserWebStorage {
  @override
  String? getItem(String key) {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      print('Error accessing localStorage: $e');
      return null;
    }
  }

  @override
  void setItem(String key, String value) {
    try {
      html.window.localStorage[key] = value;
    } catch (e) {
      print('Error setting localStorage: $e');
    }
  }
} 