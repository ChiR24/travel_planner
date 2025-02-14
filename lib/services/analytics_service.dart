import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebasePerformance _performance;
  final FirebaseCrashlytics _crashlytics;

  AnalyticsService({
    FirebaseAnalytics? analytics,
    FirebasePerformance? performance,
    FirebaseCrashlytics? crashlytics,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _performance = performance ?? FirebasePerformance.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  // Initialize analytics
  Future<void> initialize() async {
    if (kDebugMode) {
      await _analytics.setAnalyticsCollectionEnabled(false);
      await _performance.setPerformanceCollectionEnabled(false);
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
    } else {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _performance.setPerformanceCollectionEnabled(true);
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }
  }

  // Track screen views
  Future<void> trackScreenView(String screenName, {String? screenClass}) async {
    await _analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
    await _logEvent('screen_view', parameters: {
      'screen_name': screenName,
      'screen_class': screenClass ?? 'unknown',
    });
  }

  // Track user actions
  Future<void> trackUserAction(String action,
      {Map<String, dynamic>? parameters}) async {
    await _logEvent('user_action', parameters: {
      'action': action,
      ...?parameters,
    });
  }

  // Track errors
  Future<void> trackError(dynamic error, StackTrace stackTrace,
      {String? reason}) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason ?? 'Application error',
    );
    await _logEvent('error', parameters: {
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      'reason': reason ?? 'unknown',
    });
  }

  // Track API calls
  Future<T> trackApiCall<T>({
    required String endpoint,
    required Future<T> Function() apiCall,
    Map<String, dynamic>? parameters,
  }) async {
    final trace = _performance.newTrace('api_call_$endpoint');
    await trace.start();

    try {
      final result = await apiCall();
      await trace.stop();

      await _logEvent('api_call_success', parameters: {
        'endpoint': endpoint,
        'duration_ms': trace.getAttribute('duration_ms'),
        ...?parameters,
      });

      return result;
    } catch (e, stack) {
      await trace.stop();
      await trackError(e, stack, reason: 'API call failed: $endpoint');

      await _logEvent('api_call_error', parameters: {
        'endpoint': endpoint,
        'error': e.toString(),
        ...?parameters,
      });

      rethrow;
    }
  }

  // Track feature usage
  Future<void> trackFeatureUsage(String feature,
      {Map<String, dynamic>? parameters}) async {
    await _logEvent('feature_used', parameters: {
      'feature': feature,
      ...?parameters,
    });
  }

  // Track user properties
  Future<void> setUserProperty(
      {required String name, required String? value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Track app performance
  Future<void> trackPerformanceMetric(String name, double value) async {
    final metric = _performance.newTrace(name);
    await metric.start();
    metric.putMetric('value', value);
    await metric.stop();

    await _logEvent('performance_metric', parameters: {
      'metric_name': name,
      'value': value,
    });
  }

  // Track search queries
  Future<void> trackSearch(String searchTerm,
      {Map<String, dynamic>? parameters}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
    await _logEvent('search', parameters: {
      'search_term': searchTerm,
      ...?parameters,
    });
  }

  // Track content views
  Future<void> trackContentView({
    required String contentType,
    required String itemId,
    String? itemName,
    Map<String, dynamic>? parameters,
  }) async {
    await _logEvent('content_view', parameters: {
      'content_type': contentType,
      'item_id': itemId,
      'item_name': itemName,
      ...?parameters,
    });
  }

  // Helper method to log events
  Future<void> _logEvent(String name,
      {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print('Failed to log event: $e');
        print(stack);
      }
    }
  }

  // Track app lifecycle events
  Future<void> trackAppOpen() async {
    await _logEvent('app_open');
  }

  Future<void> trackAppBackground() async {
    await _logEvent('app_background');
  }

  Future<void> trackAppForeground() async {
    await _logEvent('app_foreground');
  }

  // Track user engagement time
  DateTime? _sessionStartTime;

  void startTrackingSession() {
    _sessionStartTime = DateTime.now();
  }

  Future<void> endTrackingSession() async {
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);
      await _logEvent('session_end', parameters: {
        'duration_seconds': duration.inSeconds,
      });
      _sessionStartTime = null;
    }
  }

  // Dispose
  void dispose() {
    endTrackingSession();
  }
}
