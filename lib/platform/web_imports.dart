import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:html' as html;

/// Initialize platform-specific services for web platform
Future<void> initializePlatformServices() async {
  // Initialize Hive for web platform
  await Hive.initFlutter();
  print('Initialized Hive for web platform');

  // Log environment variables for debugging
  print('Environment variables loaded:');
  print(
      'USE_MOCK_DATA: ${html.window.localStorage['USE_MOCK_DATA'] ?? 'not set'}');
}

/// Initialize provider-specific services for web platform
Future<void> initializeProviderServices<T>(Ref ref) async {
  // Web platform doesn't need connectivity monitoring
  print('Skipping connectivity monitoring on web platform');

  // Web platform doesn't support notifications in the same way
  print('Skipping notification service initialization on web platform');

  // Initialize a simplified trip management service for web
  print('Initializing simplified trip management for web platform');

  // Log that we're using web-specific implementations
  print('Using web-specific service implementations');
}
