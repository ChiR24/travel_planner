import 'dart:async';
import 'package:flutter/foundation.dart';
import 'base_service_response.dart';

/// Metrics for tracking service performance and usage
class ServiceMetric {
  final String operation;
  final Duration duration;
  final bool isSuccess;
  final ServiceErrorCode? errorCode;
  final DateTime timestamp;

  ServiceMetric({
    required this.operation,
    required this.duration,
    required this.isSuccess,
    this.errorCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Service for tracking metrics across the application
class MetricsService {
  final List<ServiceMetric> _metrics = [];
  final _metricsController = StreamController<List<ServiceMetric>>.broadcast();

  List<ServiceMetric> get metrics => List.unmodifiable(_metrics);
  Stream<List<ServiceMetric>> get metricsStream => _metricsController.stream;

  final _listeners = <void Function(ServiceMetric)>{};
  Timer? _cleanupTimer;
  final Duration _retentionPeriod;
  bool _disposed = false;

  MetricsService({
    Duration? retentionPeriod,
    Duration? cleanupInterval,
  }) : _retentionPeriod = retentionPeriod ?? const Duration(hours: 1) {
    _startCleanupTimer(cleanupInterval ?? const Duration(minutes: 15));
  }

  void _startCleanupTimer(Duration interval) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) => _cleanup());
  }

  /// Force an immediate cleanup (useful for testing)
  @visibleForTesting
  void forceCleanup() {
    _cleanup();
  }

  void _cleanup() {
    if (_disposed) return;

    final cutoff = DateTime.now().subtract(_retentionPeriod);
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(cutoff));
    _metricsController.add(_metrics);
  }

  /// Track an operation with metrics
  Future<ServiceResponse<T>> trackOperation<T>({
    required String operation,
    required Future<ServiceResponse<T>> Function() action,
    Map<String, dynamic> attributes = const {},
  }) async {
    if (_disposed) {
      throw StateError('MetricsService has been disposed');
    }

    final stopwatch = Stopwatch()..start();
    ServiceResponse<T>? response;

    try {
      response = await action();
      final metric = ServiceMetric(
        operation: operation,
        duration: stopwatch.elapsed,
        isSuccess: response.isSuccess,
        errorCode: response.errorCode,
      );

      addMetric(metric);
      return response;
    } catch (e) {
      final errorResponse = ServiceResponse<T>.error(
        code: ServiceErrorCode.unknown,
        message: e.toString(),
      );
      final metric = ServiceMetric(
        operation: operation,
        duration: stopwatch.elapsed,
        isSuccess: false,
        errorCode: errorResponse.errorCode,
      );

      addMetric(metric);
      return errorResponse;
    } finally {
      stopwatch.stop();
    }
  }

  /// Record metrics directly
  void addMetric(ServiceMetric metric) {
    if (_disposed) {
      throw StateError('MetricsService has been disposed');
    }

    _metrics.add(metric);
    _metricsController.add(_metrics);
    for (final listener in _listeners) {
      try {
        listener(metric);
      } catch (e) {
        if (kDebugMode) {
          print('Error in metrics listener: $e');
        }
      }
    }
  }

  /// Add a listener for metrics events
  void addListener(void Function(ServiceMetric) listener) {
    _listeners.add(listener);
  }

  /// Remove a metrics listener
  void removeListener(void Function(ServiceMetric) listener) {
    _listeners.remove(listener);
  }

  /// Get metrics for a specific operation
  List<ServiceMetric> getMetricsForOperation(String operation) {
    return _metrics
        .where((m) => m.operation == operation)
        .toList(growable: false);
  }

  /// Get metrics within a time range
  List<ServiceMetric> getMetricsInRange(DateTime start, DateTime end) {
    return _metrics
        .where((m) => m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
        .toList(growable: false);
  }

  /// Get error metrics
  List<ServiceMetric> getErrorMetrics() {
    return _metrics.where((m) => !m.isSuccess).toList(growable: false);
  }

  /// Calculate average duration for an operation
  Duration? getAverageDuration(String operation) {
    final metrics = getMetricsForOperation(operation);
    if (metrics.isEmpty) return null;

    final total = metrics.fold<int>(
      0,
      (sum, m) => sum + m.duration.inMilliseconds,
    );
    return Duration(milliseconds: total ~/ metrics.length);
  }

  /// Calculate success rate for an operation
  double? getSuccessRate(String operation) {
    final metrics = getMetricsForOperation(operation);
    if (metrics.isEmpty) return null;

    final successful = metrics.where((m) => m.isSuccess).length;
    return successful / metrics.length;
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_metrics.isEmpty) {
      return {'message': 'No metrics recorded'};
    }

    final operations = _metrics.map((m) => m.operation).toSet();
    final summary = <String, dynamic>{};

    for (final operation in operations) {
      final metrics = getMetricsForOperation(operation);
      final successRate = getSuccessRate(operation);
      final avgDuration = getAverageDuration(operation);

      summary[operation] = {
        'count': metrics.length,
        'success_rate': successRate?.toStringAsFixed(2),
        'avg_duration_ms': avgDuration?.inMilliseconds,
        'error_count': metrics.where((m) => !m.isSuccess).length,
      };
    }

    return summary;
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
    _metricsController.add(_metrics);
  }

  /// Dispose of the metrics service
  void dispose() {
    _disposed = true;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _metrics.clear();
    _listeners.clear();
    _metricsController.close();
  }

  double get averageResponseTime {
    if (_metrics.isEmpty) return 0;
    final total = _metrics.fold<int>(
      0,
      (sum, metric) => sum + metric.duration.inMilliseconds,
    );
    return total / _metrics.length;
  }

  double get errorRate {
    if (_metrics.isEmpty) return 0;
    final errorCount = _metrics.where((m) => !m.isSuccess).length;
    return errorCount / _metrics.length;
  }
}

/// Extension methods for MetricsService
extension MetricsServiceExtensions on MetricsService {
  /// Track a synchronous operation
  ServiceResponse<T> trackSync<T>({
    required String operation,
    required ServiceResponse<T> Function() action,
    Map<String, dynamic> attributes = const {},
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      final response = action();
      final metric = ServiceMetric(
        operation: operation,
        duration: stopwatch.elapsed,
        isSuccess: response.isSuccess,
        errorCode: response.errorCode,
      );

      addMetric(metric);
      return response;
    } catch (e) {
      final errorResponse = ServiceResponse<T>.error(
        code: ServiceErrorCode.unknown,
        message: e.toString(),
      );
      final metric = ServiceMetric(
        operation: operation,
        duration: stopwatch.elapsed,
        isSuccess: false,
        errorCode: errorResponse.errorCode,
      );

      addMetric(metric);
      return errorResponse;
    } finally {
      stopwatch.stop();
    }
  }

  /// Track multiple operations as a batch
  Future<List<ServiceResponse<T>>> trackBatch<T>({
    required String operation,
    required List<Future<ServiceResponse<T>> Function()> actions,
    Map<String, dynamic> attributes = const {},
  }) async {
    final responses = <ServiceResponse<T>>[];

    for (var i = 0; i < actions.length; i++) {
      final response = await trackOperation(
        operation: '${operation}_$i',
        action: actions[i],
        attributes: {
          ...attributes,
          'batch_index': i,
          'batch_size': actions.length,
        },
      );
      responses.add(response);
    }

    return responses;
  }
}
