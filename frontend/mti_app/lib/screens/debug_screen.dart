import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../core/environment.dart';
import '../core/constants.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Debug screen for development purposes
/// This screen allows developers to view and change environment settings
class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isProductionMode = Environment.isProductionUrl;
  List<String> _logEntries = [];

  @override
  void initState() {
    super.initState();
    _logCurrentSettings();
  }

  void _logCurrentSettings() {
    setState(() {
      _logEntries = [
        "Environment: ${_isProductionMode ? 'PRODUCTION' : 'DEVELOPMENT'}",
        "Base URL: ${AppConstants.baseUrl}",
        "API V1 URL: ${AppConstants.apiV1BaseUrl}",
        "Web API V1 URL: ${Environment.webApiV1Url}",
        "Default API V1 URL: ${Environment.apiV1Url}",
        "Request Timeout: ${AppConstants.requestTimeout}s",
      ];
    });
    developer.log('Debug screen opened', name: 'MTI.Debug');
    ApiService.logApiConfiguration();
  }

  void _toggleEnvironment() {
    ApiService.toggleEnvironment();
    setState(() {
      _isProductionMode = Environment.isProductionUrl;
      _logCurrentSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _logCurrentSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Environment Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Environment Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Production Mode:'),
                        Switch(
                          value: _isProductionMode,
                          onChanged: (value) => _toggleEnvironment(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Environment: ${_isProductionMode ? 'PRODUCTION' : 'DEVELOPMENT'}',
                      style: TextStyle(
                        color: _isProductionMode ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Log entries
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._logEntries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(entry),
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test connection button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Connection Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _testApiConnection,
                      icon: const Icon(Icons.network_check),
                      label: const Text('Test Connection'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add a simple toggle switch for production/development URLs
            ElevatedButton(
              onPressed: () {
                // Toggle the environment
                Environment.isProductionUrl = !Environment.isProductionUrl;
                
                // Log the change
                final mode = Environment.isProductionUrl ? 'PRODUCTION' : 'DEVELOPMENT';
                print('Environment switched to $mode mode');
                ApiService.logApiConfiguration();
                
                // Show a toast or snackbar to inform the user
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Switched to $mode URLs'),
                  duration: const Duration(seconds: 2),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Environment.isProductionUrl ? Colors.green : Colors.blue,
              ),
              child: Text(
                'URL Mode: ${Environment.isProductionUrl ? "PRODUCTION" : "DEVELOPMENT"}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testApiConnection() async {
    // You could implement a simple connection test here
    final scaffold = ScaffoldMessenger.of(context);
    
    try {
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Testing connection...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      // Use a simple endpoint like app-info which doesn't require authentication
      final url = '${AppConstants.apiV1BaseUrl}/app-info';
      developer.log('Testing connection to: $url', name: 'MTI.Debug');
      
      const timeout = Duration(seconds: 5);
      
      // Use http package instead of HttpClient
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(timeout);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Connection successful! (${response.statusCode})'),
            backgroundColor: Colors.green,
          ),
        );
        developer.log('Connection successful: ${response.body}', name: 'MTI.Debug');
      } else {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Connection failed with status ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
        developer.log('Connection failed with status ${response.statusCode}: ${response.body}', name: 'MTI.Debug');
      }
    } catch (e) {
      developer.log('Connection test failed', name: 'MTI.Debug', error: e);
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Connection failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 