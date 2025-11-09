import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoggerService {
  late final Logger _logger;
  final FirebaseCrashlytics? _crashlytics;
  final bool _enableCrashlytics;
  PackageInfo? _packageInfo;
  Map<String, dynamic>? _deviceInfo;

  LoggerService({
    Logger? logger,
    FirebaseCrashlytics? crashlytics,
    bool enableCrashlytics = !kDebugMode,
  })  : _crashlytics = crashlytics,
        _enableCrashlytics = enableCrashlytics {
    _logger = logger ??
        Logger(
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
          level: kDebugMode ? Level.verbose : Level.warning,
        );

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        _deviceInfo = _convertWebDeviceInfo(await deviceInfo.webBrowserInfo);
      } else {
        if (defaultTargetPlatform == TargetPlatform.android) {
          _deviceInfo = _convertAndroidDeviceInfo(await deviceInfo.androidInfo);
      }

      if (_enableCrashlytics && _crashlytics != null) {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);
        if (_packageInfo != null) {
          await _crashlytics.setCustomKey('app_version', _packageInfo!.version);
          await _crashlytics.setCustomKey(
              'build_number', _packageInfo!.buildNumber);
        }
        if (_deviceInfo != null) {
          for (final entry in _deviceInfo!.entries) {
            await _crashlytics.setCustomKey(entry.key, entry.value.toString());
          }
        }
      }
    } catch (e, stack) {
      _logger.e('Failed to initialize logger service', e, stack);
    }
  }

  // Log levels
  void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
    _recordError(message, error, stackTrace, isFatal: false);
  }

  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
    _recordError(message, error, stackTrace, isFatal: true);
  }

  // Record error to Crashlytics
  Future<void> _recordError(
    String message,
    dynamic error,
    StackTrace? stackTrace, {
    bool isFatal = false,
  }) async {
    if (!_enableCrashlytics || _crashlytics == null) return;

    try {
      await _crashlytics.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: isFatal,
      );
    } catch (e) {
      _logger.e('Failed to record error to Crashlytics', e);
    }
  }

  // Device info helpers
  Map<String, dynamic> _convertWebDeviceInfo(WebBrowserInfo info) {
    return {
      'browser': info.browserName.toString(),
      'platform': info.platform,
      'user_agent': info.userAgent,
      'language': info.language,
    };
  }

  Map<String, dynamic> _convertAndroidDeviceInfo(AndroidDeviceInfo info) {
    return {
      'brand': info.brand,
      'device': info.device,
      'manufacturer': info.manufacturer,
      'model': info.model,
      'version': info.version.release,
      'sdk_int': info.version.sdkInt,
    };
  }


  // Log groups
  void beginGroup(String message) {
    if (kDebugMode) {
      print('\n┌── Begin: $message ──────────────────');
    }
  }

  void endGroup(String message) {
    if (kDebugMode) {
      print('└── End: $message ────────────────────\n');
    }
  }

  // Performance logging
  void logPerformance(String operation, Duration duration) {
    i('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  // Network logging
  void logRequest(String method, String url, {Map<String, dynamic>? headers}) {
    d('→ $method $url', headers);
  }

  void logResponse(String method, String url, int statusCode, dynamic body) {
    if (statusCode >= 200 && statusCode < 300) {
      d('← $method $url [$statusCode]', body);
    } else {
      w('← $method $url [$statusCode]', body);
    }
  }

  // State logging
  void logState(String state, {Map<String, dynamic>? data}) {
    d('State: $state', data);
  }

  // User action logging
  void logUserAction(String action, {Map<String, dynamic>? data}) {
    i('User Action: $action', data);
  }

  // Error boundary logging
  void logErrorBoundary(dynamic error, StackTrace stackTrace) {
    e('Error Boundary Caught:', error, stackTrace);
  }

  // Dispose
  void dispose() {
    // Clean up any resources if needed
  }
}
