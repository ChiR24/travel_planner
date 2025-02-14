import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_service.dart';
import 'service_registry.dart';

/// Status of service initialization
enum ServiceInitializationStatus {
  notStarted,
  inProgress,
  completed,
  failed,
}

/// Result of service initialization
class ServiceInitializationResult {
  final bool success;
  final List<ServiceException> errors;
  final Duration duration;
  final Map<Type, bool> serviceStatus;

  const ServiceInitializationResult({
    required this.success,
    required this.errors,
    required this.duration,
    required this.serviceStatus,
  });
}

/// Service initialization progress
class ServiceInitializationProgress {
  final int totalServices;
  final int completedServices;
  final List<Type> initializedServices;
  final List<Type> failedServices;
  final Duration elapsed;

  const ServiceInitializationProgress({
    required this.totalServices,
    required this.completedServices,
    required this.initializedServices,
    required this.failedServices,
    required this.elapsed,
  });

  double get progress =>
      totalServices == 0 ? 0 : completedServices / totalServices;

  bool get isComplete => completedServices == totalServices;
}

/// Service dependency graph
class ServiceDependencyGraph {
  final Map<Type, Set<Type>> dependencies;

  const ServiceDependencyGraph(this.dependencies);

  List<List<Type>> getInitializationOrder() {
    final visited = <Type>{};
    final result = <List<Type>>[];

    void visit(Type type, Set<Type> processing) {
      if (processing.contains(type)) {
        throw ServiceException(
          'Circular dependency detected',
          serviceName: type.toString(),
        );
      }

      if (visited.contains(type)) return;

      processing.add(type);

      final deps = dependencies[type] ?? {};
      for (final dep in deps) {
        visit(dep, processing);
      }

      processing.remove(type);
      visited.add(type);

      var level = result.length - 1;
      while (level >= 0) {
        if (result[level]
            .any((t) => dependencies[type]?.contains(t) ?? false)) {
          level--;
        } else {
          break;
        }
      }

      if (level == result.length - 1) {
        result[level].add(type);
      } else {
        result.add([type]);
      }
    }

    for (final type in dependencies.keys) {
      visit(type, {});
    }

    return result;
  }
}

/// Service initializer for managing startup sequence
class ServiceInitializer extends StateNotifier<ServiceInitializationStatus> {
  final ServiceRegistry _registry;
  final ServiceDependencyGraph _dependencyGraph;
  final void Function(ServiceInitializationProgress)? onProgress;
  final bool _throwOnError;

  ServiceInitializer({
    required ServiceRegistry registry,
    required ServiceDependencyGraph dependencyGraph,
    this.onProgress,
    bool throwOnError = false,
  })  : _registry = registry,
        _dependencyGraph = dependencyGraph,
        _throwOnError = throwOnError,
        super(ServiceInitializationStatus.notStarted);

  /// Initialize all services in dependency order
  Future<ServiceInitializationResult> initialize() async {
    if (state == ServiceInitializationStatus.inProgress) {
      throw ServiceException(
        'Service initialization already in progress',
        serviceName: 'ServiceInitializer',
      );
    }

    state = ServiceInitializationStatus.inProgress;
    final stopwatch = Stopwatch()..start();
    final errors = <ServiceException>[];
    final serviceStatus = <Type, bool>{};

    try {
      final initOrder = _dependencyGraph.getInitializationOrder();
      final totalServices = _registry.registeredServices.length;
      var completedServices = 0;
      final initializedServices = <Type>[];
      final failedServices = <Type>[];

      for (final group in initOrder) {
        await Future.wait(
          group.map((type) async {
            try {
              final service = _registry.get<BaseService>();
              await service.initialize();
              serviceStatus[type] = true;
              initializedServices.add(type);
              completedServices++;
            } catch (e, stack) {
              serviceStatus[type] = false;
              failedServices.add(type);
              completedServices++;
              final error = ServiceException(
                'Failed to initialize service',
                serviceName: type.toString(),
                originalError: e,
                stackTrace: stack,
              );
              errors.add(error);
              if (_throwOnError) {
                throw error;
              }
            } finally {
              onProgress?.call(
                ServiceInitializationProgress(
                  totalServices: totalServices,
                  completedServices: completedServices,
                  initializedServices: initializedServices,
                  failedServices: failedServices,
                  elapsed: stopwatch.elapsed,
                ),
              );
            }
          }),
        );
      }

      state = errors.isEmpty
          ? ServiceInitializationStatus.completed
          : ServiceInitializationStatus.failed;

      return ServiceInitializationResult(
        success: errors.isEmpty,
        errors: errors,
        duration: stopwatch.elapsed,
        serviceStatus: serviceStatus,
      );
    } catch (e, stack) {
      state = ServiceInitializationStatus.failed;
      final error = ServiceException(
        'Service initialization failed',
        serviceName: 'ServiceInitializer',
        originalError: e,
        stackTrace: stack,
      );
      errors.add(error);
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Reset initialization status
  void reset() {
    state = ServiceInitializationStatus.notStarted;
  }
}

/// Provider for the service initializer
final serviceInitializerProvider =
    StateNotifierProvider<ServiceInitializer, ServiceInitializationStatus>(
        (ref) {
  final registry = ref.watch(serviceRegistryProvider.notifier);
  final dependencyGraph = ServiceDependencyGraph({
    // Define your service dependencies here
    // Example:
    // NetworkService: {LoggerService},
    // CacheService: {NetworkService},
  });

  return ServiceInitializer(
    registry: registry,
    dependencyGraph: dependencyGraph,
    onProgress: (progress) {
      if (kDebugMode) {
        print(
          'Service initialization progress: ${(progress.progress * 100).toStringAsFixed(1)}%',
        );
      }
    },
  );
});

/// Extension methods for service initialization
extension ServiceInitializerExtensions on WidgetRef {
  /// Initialize all services
  Future<ServiceInitializationResult> initializeServices() async {
    final initializer = read(serviceInitializerProvider.notifier);
    return initializer.initialize();
  }

  /// Get current initialization status
  ServiceInitializationStatus get initializationStatus =>
      read(serviceInitializerProvider);

  /// Reset initialization status
  void resetInitialization() {
    read(serviceInitializerProvider.notifier).reset();
  }
}
