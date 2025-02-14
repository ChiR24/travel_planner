import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';

class AppConfigService {
  static const String _configKey = 'app_config';
  final SharedPreferences _prefs;

  AppConfigService(this._prefs);

  // Default configuration
  static const Map<String, dynamic> _defaultConfig = {
    'theme': {
      'mode': 'system', // system, light, dark
      'primaryColor': 0xFF1E88E5,
      'secondaryColor': 0xFF26A69A,
      'fontFamily': 'Poppins',
    },
    'features': {
      'offlineMode': true,
      'analytics': true,
      'pushNotifications': true,
      'locationServices': true,
      'autoSync': true,
      'debugMode': false,
    },
    'api': {
      'baseUrl': 'https://api.example.com/v1',
      'timeout': 30000, // milliseconds
      'retryAttempts': 3,
      'cacheExpiration': 3600, // seconds
    },
    'cache': {
      'maxSize': 100 * 1024 * 1024, // 100MB
      'cleanupThreshold': 0.9, // 90%
      'expirationTime': 7 * 24 * 3600, // 7 days in seconds
    },
    'performance': {
      'imageQuality': 85,
      'maxImageDimension': 1200,
      'prefetchLimit': 10,
      'lazyLoadThreshold': 500,
    },
    'accessibility': {
      'fontScale': 1.0,
      'highContrast': false,
      'reduceMotion': false,
      'screenReader': false,
    },
  };

  // Get current configuration
  Map<String, dynamic> get config {
    final storedConfig = _prefs.getString(_configKey);
    if (storedConfig == null) return _defaultConfig;

    try {
      return Map<String, dynamic>.from(jsonDecode(storedConfig));
    } catch (e) {
      return _defaultConfig;
    }
  }

  // Update configuration
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    final currentConfig = config;
    final updatedConfig = _mergeConfig(currentConfig, newConfig);
    await _prefs.setString(_configKey, jsonEncode(updatedConfig));
  }

  // Reset configuration to defaults
  Future<void> resetConfig() async {
    await _prefs.setString(_configKey, jsonEncode(_defaultConfig));
  }

  // Helper method to merge configurations
  Map<String, dynamic> _mergeConfig(
    Map<String, dynamic> current,
    Map<String, dynamic> update,
  ) {
    final merged = Map<String, dynamic>.from(current);
    for (final entry in update.entries) {
      if (entry.value is Map<String, dynamic> &&
          merged[entry.key] is Map<String, dynamic>) {
        merged[entry.key] = _mergeConfig(
          merged[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  // Getters for commonly used configuration values
  ThemeMode get themeMode {
    final mode = config['theme']['mode'] as String;
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Color get primaryColor => Color(config['theme']['primaryColor'] as int);

  Color get secondaryColor => Color(config['theme']['secondaryColor'] as int);

  String get fontFamily => config['theme']['fontFamily'] as String;

  bool get isOfflineModeEnabled => config['features']['offlineMode'] as bool;

  bool get isAnalyticsEnabled => config['features']['analytics'] as bool;

  bool get isPushNotificationsEnabled =>
      config['features']['pushNotifications'] as bool;

  bool get isLocationServicesEnabled =>
      config['features']['locationServices'] as bool;

  bool get isAutoSyncEnabled => config['features']['autoSync'] as bool;

  bool get isDebugModeEnabled => config['features']['debugMode'] as bool;

  String get apiBaseUrl => config['api']['baseUrl'] as String;

  int get apiTimeout => config['api']['timeout'] as int;

  int get apiRetryAttempts => config['api']['retryAttempts'] as int;

  int get apiCacheExpiration => config['api']['cacheExpiration'] as int;

  int get cacheMaxSize => config['cache']['maxSize'] as int;

  double get cacheCleanupThreshold =>
      config['cache']['cleanupThreshold'] as double;

  int get cacheExpirationTime => config['cache']['expirationTime'] as int;

  int get imageQuality => config['performance']['imageQuality'] as int;

  int get maxImageDimension =>
      config['performance']['maxImageDimension'] as int;

  int get prefetchLimit => config['performance']['prefetchLimit'] as int;

  int get lazyLoadThreshold =>
      config['performance']['lazyLoadThreshold'] as int;

  double get fontScale => config['accessibility']['fontScale'] as double;

  bool get isHighContrastEnabled =>
      config['accessibility']['highContrast'] as bool;

  bool get isReduceMotionEnabled =>
      config['accessibility']['reduceMotion'] as bool;

  bool get isScreenReaderEnabled =>
      config['accessibility']['screenReader'] as bool;

  // Feature flag methods
  bool isFeatureEnabled(String feature) {
    return config['features'][feature] as bool? ?? false;
  }

  // Theme-related methods
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = mode.toString().split('.').last;
    await updateConfig({
      'theme': {'mode': modeString}
    });
  }

  // Accessibility methods
  Future<void> setFontScale(double scale) async {
    await updateConfig({
      'accessibility': {'fontScale': scale}
    });
  }

  Future<void> setHighContrast(bool enabled) async {
    await updateConfig({
      'accessibility': {'highContrast': enabled}
    });
  }

  Future<void> setReduceMotion(bool enabled) async {
    await updateConfig({
      'accessibility': {'reduceMotion': enabled}
    });
  }

  // Performance methods
  Future<void> setImageQuality(int quality) async {
    await updateConfig({
      'performance': {'imageQuality': quality}
    });
  }

  // Feature toggle methods
  Future<void> toggleFeature(String feature, bool enabled) async {
    await updateConfig({
      'features': {feature: enabled}
    });
  }
}

// Provider
final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  throw UnimplementedError('Initialize with SharedPreferences instance');
});
