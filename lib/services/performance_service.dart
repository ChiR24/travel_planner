import 'dart:async';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

class PerformanceService {
  final FirebasePerformance _performance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final LoggerService _logger;
  final Map<String, Trace> _activeTraces = {};
  final Map<String, HttpMetric> _activeHttpMetrics = {};
  final Map<String, DateTime> _frameTimestamps = {};
  final bool _enabled;

  PerformanceService({
    FirebasePerformance? performance,
    LoggerService? logger,
    bool enabled = !kDebugMode,
  })  : _performance = performance ?? FirebasePerformance.instance,
        _logger = logger ?? LoggerService(),
        _enabled = enabled {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_enabled) {
      await _performance.setPerformanceCollectionEnabled(true);
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      // Set user properties for better analytics
      await _analytics.setAnalyticsCollectionEnabled(true);
      _logger.i('Performance monitoring initialized');
    }
  }

  // Custom trace tracking
  Future<T> trackOperation<T>({
    required String name,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    if (!_enabled) return operation();

    final trace = _performance.newTrace(name);
    _activeTraces[name] = trace;
    final stopwatch = Stopwatch()..start();

    try {
      await trace.start();
      if (attributes != null) {
        attributes.forEach((key, value) {
          trace.putAttribute(key, value);
        });
      }
      if (metrics != null) {
        metrics.forEach((key, value) {
          trace.putMetric(key, value);
        });
      }

      final result = await operation();
      trace.putMetric('duration_ms', stopwatch.elapsedMilliseconds);
      return result;
    } catch (e, stack) {
      trace.putAttribute('error', e.toString());
      _logger.e('Error in operation $name', e, stack);
      rethrow;
    } finally {
      await trace.stop();
      _activeTraces.remove(name);
      stopwatch.stop();
      _logger.logPerformance(name, stopwatch.elapsed);
    }
  }

  // HTTP request tracking
  Future<T> trackHttpRequest<T>({
    required String url,
    required String method,
    required Future<T> Function() request,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  }) async {
    if (!_enabled) return request();

    final metric = _performance.newHttpMetric(url, _getHttpMethod(method));
    _activeHttpMetrics[url] = metric;
    final stopwatch = Stopwatch()..start();

    try {
      await metric.start();
      if (requestHeaders != null) {
        requestHeaders.forEach((key, value) {
          metric.putAttribute('req_$key', value);
        });
      }

      final result = await request();

      if (responseHeaders != null) {
        responseHeaders.forEach((key, value) {
          metric.putAttribute('res_$key', value);
        });
      }

      metric.putAttribute('success', 'true');
      return result;
    } catch (e, stack) {
      metric.putAttribute('error', e.toString());
      metric.putAttribute('success', 'false');
      _logger.e('Error in HTTP request $url', e, stack);
      rethrow;
    } finally {
      await metric.stop();
      _activeHttpMetrics.remove(url);
      stopwatch.stop();
      _logger.logPerformance('HTTP $method $url', stopwatch.elapsed);
    }
  }

  // Frame rendering tracking
  void startFrame(String name) {
    if (!_enabled) return;
    _frameTimestamps[name] = DateTime.now();
  }

  void endFrame(String name) {
    if (!_enabled) return;
    final startTime = _frameTimestamps.remove(name);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logger.logPerformance('Frame $name', duration);
    }
  }

  // Memory tracking
  void trackMemoryUsage(String operation) {
    if (!_enabled) return;
    // Note: This is a simplified version. In a real app, you'd want to use
    // platform-specific memory tracking APIs for more accurate measurements.
    final trace = _performance.newTrace('memory_$operation');
    trace.putMetric('timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Helper methods
  HttpMethod _getHttpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'OPTIONS':
        return HttpMethod.Options;
      default:
        return HttpMethod.Get;
    }
  }

  // Cleanup
  Future<void> dispose() async {
    for (final trace in _activeTraces.values) {
      await trace.stop();
    }
    _activeTraces.clear();

    for (final metric in _activeHttpMetrics.values) {
      await metric.stop();
    }
    _activeHttpMetrics.clear();
    _frameTimestamps.clear();
  }

  // Track screen views
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
  }

  // Track user actions
  Future<void> trackUserAction({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        ...?parameters,
      },
    );
  }

  // Track errors
  Future<void> trackError(dynamic error, StackTrace stackTrace) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: 'Application error',
    );
  }

  // Custom performance markers
  void markTime(String name) {
    _performance.trace(name);
  }

  // Track app startup time
  Future<void> trackAppStartup() async {
    final trace = _performance.newTrace('app_startup');
    await trace.start();

    // Add startup metrics
    trace.putMetric(
        'startup_time', DateTime.now().millisecondsSinceEpoch.toDouble());

    await trace.stop();
  }
}

// Extension for easy performance tracking
extension PerformanceTrackingExtension on PerformanceService {
  Future<T> trackNetworkOperation<T>({
    required String name,
    required String url,
    required String method,
    required Future<T> Function() operation,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  }) async {
    return trackOperation(
      name: 'network_$name',
      operation: () => trackHttpRequest(
        url: url,
        method: method,
        request: operation,
        requestHeaders: requestHeaders,
        responseHeaders: responseHeaders,
      ),
    );
  }

  Future<T> trackDatabaseOperation<T>({
    required String name,
    required Future<T> Function() operation,
  }) async {
    return trackOperation(
      name: 'db_$name',
      operation: operation,
      attributes: {'type': 'database'},
    );
  }

  Future<T> trackUiOperation<T>({
    required String name,
    required Future<T> Function() operation,
  }) async {
    startFrame(name);
    try {
      return await trackOperation(
        name: 'ui_$name',
        operation: operation,
        attributes: {'type': 'ui'},
      );
    } finally {
      endFrame(name);
    }
  }
}
