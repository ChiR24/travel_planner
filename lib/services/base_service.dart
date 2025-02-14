import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base interface that all services must implement
abstract class BaseService {
  /// Initialize the service
  Future<void> initialize();

  /// Dispose of any resources used by the service
  Future<void> dispose();

  /// Check if the service is initialized
  bool get isInitialized;

  /// Reset the service to its initial state
  Future<void> reset();

  /// Get the service name
  String get serviceName;
}

/// Mixin for services that need to handle errors
mixin ErrorHandling {
  /// Log an error with optional stack trace
  void logError(Object error, [StackTrace? stackTrace]);

  /// Handle an error appropriately
  Future<void> handleError(Object error, [StackTrace? stackTrace]);

  /// Check if an error is recoverable
  bool isRecoverableError(Object error);
}

/// Mixin for services that need to handle state
mixin StateManagement<T> {
  /// Get the current state
  T get currentState;

  /// Update the state
  Future<void> updateState(T newState);

  /// Reset the state
  Future<void> resetState();
}

/// Mixin for services that need to handle configuration
mixin ConfigurationManagement {
  /// Get the current configuration
  Map<String, dynamic> get configuration;

  /// Update the configuration
  Future<void> updateConfiguration(Map<String, dynamic> newConfig);

  /// Reset the configuration to defaults
  Future<void> resetConfiguration();
}

/// Base class for service providers
abstract class BaseServiceProvider<T extends BaseService>
    extends StateNotifier<T?> {
  BaseServiceProvider(super.state);

  /// Initialize the service
  Future<void> initialize();

  /// Dispose of the service
  @override
  Future<void> dispose();

  /// Reset the service
  Future<void> reset();
}

/// Base class for service exceptions
class ServiceException implements Exception {
  final String message;
  final String serviceName;
  final Object? originalError;
  final StackTrace? stackTrace;

  ServiceException(
    this.message, {
    required this.serviceName,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'ServiceException[$serviceName]: $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
  }
}

/// Extension methods for services
extension ServiceExtensions on BaseService {
  /// Log a message with the service name
  void log(String message) {
    if (kDebugMode) {
      print('[$serviceName] $message');
    }
  }

  /// Create a service-specific exception
  ServiceException createException(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return ServiceException(
      message,
      serviceName: serviceName,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

/// Provider for accessing services
final serviceProvider = Provider<Map<Type, BaseService>>((ref) {
  return {};
});

/// Extension methods for accessing services through providers
extension ServiceProviderExtensions on ProviderRef {
  /// Get a service by type
  T getService<T extends BaseService>() {
    final services = read(serviceProvider);
    final service = services[T];
    if (service == null) {
      throw ServiceException(
        'Service not found',
        serviceName: T.toString(),
      );
    }
    return service as T;
  }

  /// Register a service
  void registerService<T extends BaseService>(T service) {
    final services = read(serviceProvider);
    (services)[T] = service;
  }

  /// Unregister a service
  void unregisterService<T extends BaseService>() {
    final services = read(serviceProvider);
    (services).remove(T);
  }
}
