import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_service.dart';
import 'service_registry.dart';

/// Health status of a service
enum ServiceHealthStatus {
  healthy,
  degraded,
  failed,
  unknown,
}

/// Health check result for a service
class ServiceHealthResult {
  final Type serviceType;
  final ServiceHealthStatus status;
  final String message;
  final DateTime timestamp;
  final Duration checkDuration;
  final Object? error;
  final StackTrace? stackTrace;

  const ServiceHealthResult({
    required this.serviceType,
    required this.status,
    required this.message,
    required this.timestamp,
    required this.checkDuration,
    this.error,
    this.stackTrace,
  });

  bool get isHealthy => status == ServiceHealthStatus.healthy;
}

/// Health check configuration for a service
class ServiceHealthCheck {
  final Duration interval;
  final Duration timeout;
  final int retryCount;
  final Duration retryDelay;
  final bool stopOnError;

  const ServiceHealthCheck({
    this.interval = const Duration(minutes: 1),
    this.timeout = const Duration(seconds: 30),
    this.retryCount = 3,
    this.retryDelay = const Duration(seconds: 5),
    this.stopOnError = false,
  });
}

/// Service monitor for tracking service health
class ServiceMonitor extends StateNotifier<Map<Type, ServiceHealthResult>> {
  final ServiceRegistry _registry;
  final Map<Type, ServiceHealthCheck> _healthChecks;
  final void Function(ServiceHealthResult)? onHealthChange;
  final Map<Type, Timer> _timers = {};
  final Map<Type, Completer<void>> _activeChecks = {};

  ServiceMonitor({
    required ServiceRegistry registry,
    required Map<Type, ServiceHealthCheck> healthChecks,
    this.onHealthChange,
  })  : _registry = registry,
        _healthChecks = healthChecks,
        super({});

  /// Start monitoring services
  void startMonitoring() {
    for (final type in _healthChecks.keys) {
      _startMonitoringService(type);
    }
  }

  /// Stop monitoring services
  void stopMonitoring() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    for (final check in _activeChecks.values) {
      check.complete();
    }
    _activeChecks.clear();
  }

  /// Start monitoring a specific service
  void _startMonitoringService(Type type) {
    final check = _healthChecks[type];
    if (check == null) return;

    void scheduleNextCheck() {
      _timers[type] = Timer(check.interval, () => _checkServiceHealth(type));
    }

    _checkServiceHealth(type).then((_) => scheduleNextCheck());
  }

  /// Check health of a specific service
  Future<void> _checkServiceHealth(Type type) async {
    if (_activeChecks[type]?.isCompleted == false) return;

    final completer = Completer<void>();
    _activeChecks[type] = completer;

    final check = _healthChecks[type];
    if (check == null) return;

    final stopwatch = Stopwatch()..start();
    ServiceHealthStatus status = ServiceHealthStatus.unknown;
    String message = '';
    Object? error;
    StackTrace? stackTrace;

    try {
      final service = _registry.get<BaseService>();
      if (!service.isInitialized) {
        throw ServiceException(
          'Service is not initialized',
          serviceName: type.toString(),
        );
      }

      // Perform health check with retry
      for (var i = 0; i <= check.retryCount; i++) {
        try {
          if (service is HealthCheck) {
            await (service).checkHealth().timeout(check.timeout);
            status = ServiceHealthStatus.healthy;
            message = 'Service is healthy';
            break;
          } else {
            status = ServiceHealthStatus.unknown;
            message = 'Service does not implement health checks';
            break;
          }
        } catch (e, stack) {
          error = e;
          stackTrace = stack;
          status = ServiceHealthStatus.degraded;
          message = 'Health check failed: ${e.toString()}';
          if (i < check.retryCount) {
            await Future.delayed(check.retryDelay);
          } else {
            status = ServiceHealthStatus.failed;
          }
        }
      }
    } catch (e, stack) {
      error = e;
      stackTrace = stack;
      status = ServiceHealthStatus.failed;
      message = 'Service error: ${e.toString()}';
    } finally {
      stopwatch.stop();
      completer.complete();
    }

    final result = ServiceHealthResult(
      serviceType: type,
      status: status,
      message: message,
      timestamp: DateTime.now(),
      checkDuration: stopwatch.elapsed,
      error: error,
      stackTrace: stackTrace,
    );

    state = {...state, type: result};
    onHealthChange?.call(result);

    if (check.stopOnError && !result.isHealthy) {
      _timers[type]?.cancel();
      _timers.remove(type);
    }
  }

  /// Get health status for a specific service
  ServiceHealthResult? getServiceHealth(Type type) => state[type];

  /// Get health status for all services
  Map<Type, ServiceHealthResult> get healthStatus => Map.unmodifiable(state);

  /// Check if all services are healthy
  bool get areAllServicesHealthy =>
      state.values.every((result) => result.isHealthy);

  /// Get list of unhealthy services
  List<Type> get unhealthyServices => state.entries
      .where((entry) => !entry.value.isHealthy)
      .map((entry) => entry.key)
      .toList();

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

/// Mixin for services that support health checks
mixin HealthCheck on BaseService {
  /// Perform a health check
  Future<void> checkHealth();
}

/// Provider for the service monitor
final serviceMonitorProvider =
    StateNotifierProvider<ServiceMonitor, Map<Type, ServiceHealthResult>>(
        (ref) {
  final registry = ref.watch(serviceRegistryProvider.notifier);
  final healthChecks = <Type, ServiceHealthCheck>{
    // Define your health checks here
    // Example:
    // NetworkService: ServiceHealthCheck(
    //   interval: Duration(minutes: 1),
    //   timeout: Duration(seconds: 30),
    // ),
  };

  final monitor = ServiceMonitor(
    registry: registry,
    healthChecks: healthChecks,
    onHealthChange: (result) {
      if (kDebugMode) {
        print(
          'Service health changed: ${result.serviceType} - ${result.status} - ${result.message}',
        );
      }
    },
  );

  ref.onDispose(() {
    monitor.dispose();
  });

  return monitor;
});

/// Extension methods for service monitoring
extension ServiceMonitorExtensions on WidgetRef {
  /// Start monitoring services
  void startServiceMonitoring() {
    read(serviceMonitorProvider.notifier).startMonitoring();
  }

  /// Stop monitoring services
  void stopServiceMonitoring() {
    read(serviceMonitorProvider.notifier).stopMonitoring();
  }

  /// Get service health status
  Map<Type, ServiceHealthResult> get serviceHealth =>
      read(serviceMonitorProvider);

  /// Check if all services are healthy
  bool get areAllServicesHealthy =>
      read(serviceMonitorProvider.notifier).areAllServicesHealthy;

  /// Get list of unhealthy services
  List<Type> get unhealthyServices =>
      read(serviceMonitorProvider.notifier).unhealthyServices;
}

/// Extension methods for service health results
extension ServiceHealthResultExtensions on ServiceHealthResult {
  /// Check if the service is in a specific status
  bool isInStatus(ServiceHealthStatus status) => this.status == status;

  /// Get a human-readable status string
  String get statusString {
    switch (status) {
      case ServiceHealthStatus.healthy:
        return 'Healthy';
      case ServiceHealthStatus.degraded:
        return 'Degraded';
      case ServiceHealthStatus.failed:
        return 'Failed';
      case ServiceHealthStatus.unknown:
        return 'Unknown';
    }
  }

  /// Get the age of the health check result
  Duration get age => DateTime.now().difference(timestamp);

  /// Check if the result is stale
  bool isStale(Duration threshold) => age > threshold;
}
