import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_service.dart';

/// Service registry for managing all application services
class ServiceRegistry extends StateNotifier<Map<Type, BaseService>> {
  ServiceRegistry() : super({});

  /// Initialize all registered services
  Future<void> initializeAll() async {
    for (final service in state.values) {
      if (!service.isInitialized) {
        await service.initialize();
      }
    }
  }

  /// Dispose of all registered services
  Future<void> disposeAll() async {
    for (final service in state.values) {
      await service.dispose();
    }
    state = {};
  }

  /// Register a service
  void register<T extends BaseService>(T service) {
    state = {...state, T: service};
  }

  /// Unregister a service
  void unregister<T extends BaseService>() {
    final newState = Map<Type, BaseService>.from(state);
    newState.remove(T);
    state = newState;
  }

  /// Get a service by type
  T get<T extends BaseService>() {
    final service = state[T];
    if (service == null) {
      throw ServiceException(
        'Service not found',
        serviceName: T.toString(),
      );
    }
    return service as T;
  }

  /// Check if a service is registered
  bool isRegistered<T extends BaseService>() {
    return state.containsKey(T);
  }

  /// Reset all services to their initial state
  Future<void> resetAll() async {
    for (final service in state.values) {
      await service.reset();
    }
  }

  /// Get all registered service types
  Set<Type> get registeredServices => state.keys.toSet();

  /// Get all initialized services
  Iterable<BaseService> get initializedServices =>
      state.values.where((service) => service.isInitialized);

  /// Get all uninitialized services
  Iterable<BaseService> get uninitializedServices =>
      state.values.where((service) => !service.isInitialized);
}

/// Provider for the service registry
final serviceRegistryProvider =
    StateNotifierProvider<ServiceRegistry, Map<Type, BaseService>>(
  (ref) => ServiceRegistry(),
);

/// Extension methods for accessing services through the registry provider
extension ServiceRegistryProviderExtensions on ProviderRef {
  /// Get the service registry
  ServiceRegistry get serviceRegistry => read(serviceRegistryProvider.notifier);

  /// Get a service by type
  T getService<T extends BaseService>() => serviceRegistry.get<T>();

  /// Register a service
  void registerService<T extends BaseService>(T service) =>
      serviceRegistry.register<T>(service);

  /// Unregister a service
  void unregisterService<T extends BaseService>() =>
      serviceRegistry.unregister<T>();
}

/// Mixin for widgets that need access to services
mixin ServiceAccessMixin {
  /// Get a service by type
  T getService<T extends BaseService>(WidgetRef ref) =>
      ref.read(serviceRegistryProvider.notifier).get<T>();
}

/// Extension methods for service initialization
extension ServiceInitializationExtensions on ServiceRegistry {
  /// Initialize a specific service
  Future<void> initializeService<T extends BaseService>() async {
    final service = get<T>();
    if (!service.isInitialized) {
      await service.initialize();
    }
  }

  /// Initialize multiple services
  Future<void> initializeServices(List<Type> serviceTypes) async {
    for (final type in serviceTypes) {
      final service = state[type];
      if (service != null && !service.isInitialized) {
        await service.initialize();
      }
    }
  }

  /// Initialize services in dependency order
  Future<void> initializeInOrder(List<List<Type>> dependencyGroups) async {
    for (final group in dependencyGroups) {
      await Future.wait(
        group.map((type) async {
          final service = state[type];
          if (service != null && !service.isInitialized) {
            await service.initialize();
          }
        }),
      );
    }
  }
}

/// Extension methods for service lifecycle management
extension ServiceLifecycleExtensions on ServiceRegistry {
  /// Restart a specific service
  Future<void> restartService<T extends BaseService>() async {
    final service = get<T>();
    await service.dispose();
    await service.initialize();
  }

  /// Restart multiple services
  Future<void> restartServices(List<Type> serviceTypes) async {
    for (final type in serviceTypes) {
      final service = state[type];
      if (service != null) {
        await service.dispose();
        await service.initialize();
      }
    }
  }

  /// Check health of all services
  Map<Type, bool> checkServicesHealth() {
    return Map.fromEntries(
      state.entries.map(
        (entry) => MapEntry(
          entry.key,
          entry.value.isInitialized,
        ),
      ),
    );
  }
}

/// Extension methods for error handling
extension ServiceErrorHandlingExtensions on ServiceRegistry {
  /// Handle an error for a specific service
  Future<void> handleServiceError<T extends BaseService>(
    Object error, [
    StackTrace? stackTrace,
  ]) async {
    final service = get<T>();
    if (service is ErrorHandling) {
      await (service as ErrorHandling).handleError(error, stackTrace);
    } else {
      throw ServiceException(
        'Service does not implement error handling',
        serviceName: T.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log an error for a specific service
  void logServiceError<T extends BaseService>(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    final service = get<T>();
    if (service is ErrorHandling) {
      (service as ErrorHandling).logError(error, stackTrace);
    } else {
      throw ServiceException(
        'Service does not implement error handling',
        serviceName: T.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }
}
