import 'package:flutter/foundation.dart';

/// Standard error codes for all services
enum ServiceErrorCode {
  networkError,
  serverError,
  authenticationError,
  validationError,
  notFound,
  unknown
}

/// Standard response format for all service operations
class ServiceResponse<T> {
  final T? data;
  final bool isSuccess;
  final ServiceErrorCode? errorCode;
  final String? errorMessage;
  final DateTime timestamp;

  ServiceResponse({
    this.data,
    required this.isSuccess,
    this.errorCode,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasError => !isSuccess;
  bool get hasData => data != null;

  /// Create a successful response
  factory ServiceResponse.success(T data) {
    return ServiceResponse(
      data: data,
      isSuccess: true,
    );
  }

  /// Create an error response
  factory ServiceResponse.error({
    ServiceErrorCode code = ServiceErrorCode.unknown,
    String? message,
  }) {
    return ServiceResponse(
      isSuccess: false,
      errorCode: code,
      errorMessage: message,
    );
  }

  /// Create a response from an exception
  factory ServiceResponse.fromException(Object error, StackTrace stackTrace) {
    if (error is ServiceException) {
      return ServiceResponse.error(
        code: error.code,
        message: error.message,
      );
    }

    return ServiceResponse.error(
      code: ServiceErrorCode.unknown,
      message: error.toString(),
    );
  }

  /// Map the response data to a new type
  ServiceResponse<R> map<R>(R Function(T data) mapper) {
    if (hasError) {
      return ServiceResponse(
        isSuccess: false,
        errorCode: errorCode,
        errorMessage: errorMessage,
        timestamp: timestamp,
      );
    }

    try {
      return ServiceResponse(
        data: mapper(data as T),
        isSuccess: true,
        timestamp: timestamp,
      );
    } catch (e) {
      return ServiceResponse.error(
        code: ServiceErrorCode.unknown,
        message: 'Error mapping response: ${e.toString()}',
      );
    }
  }

  /// Handle both success and error cases
  R when<R>({
    required R Function(T data) success,
    required R Function(ServiceErrorCode code, String message) error,
  }) {
    if (hasError) {
      return error(errorCode!, errorMessage!);
    }
    return success(data as T);
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ServiceResponse(success: true, data: $data)';
    }
    return 'ServiceResponse(success: false, error: [$errorCode] $errorMessage)';
  }
}

/// Base exception class for all service errors
class ServiceException implements Exception {
  final ServiceErrorCode code;
  final String message;

  const ServiceException(this.code, this.message);

  @override
  String toString() => 'ServiceException[${code.name}]: $message';
}

/// Configuration for retry strategies
class RetryConfig {
  final int maxAttempts;
  final Duration delay;
  final bool exponential;
  final bool Function(ServiceErrorCode)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.delay = const Duration(seconds: 1),
    this.exponential = true,
    this.shouldRetry,
  });

  Duration getDelayForAttempt(int attempt) {
    if (!exponential) return delay;
    return delay * (attempt + 1);
  }

  bool shouldRetryError(ServiceErrorCode code) {
    if (shouldRetry != null) return shouldRetry!(code);

    // Default retry strategy
    switch (code) {
      case ServiceErrorCode.networkError:
      case ServiceErrorCode.serverError:
      case ServiceErrorCode.authenticationError:
      case ServiceErrorCode.validationError:
      case ServiceErrorCode.notFound:
        return true;
      default:
        return false;
    }
  }
}

/// Mixin for services that support retrying operations
mixin RetrySupport {
  /// Execute an operation with retry support
  Future<ServiceResponse<T>> withRetry<T>({
    required Future<ServiceResponse<T>> Function() operation,
    RetryConfig? config,
  }) async {
    final retryConfig = config ?? const RetryConfig();
    ServiceResponse<T>? lastResponse;

    for (var attempt = 0; attempt < retryConfig.maxAttempts; attempt++) {
      try {
        final response = await operation();
        if (!response.hasError) return response;

        lastResponse = response;
        if (!retryConfig.shouldRetryError(response.errorCode!)) {
          return response;
        }

        if (attempt < retryConfig.maxAttempts - 1) {
          await Future.delayed(retryConfig.getDelayForAttempt(attempt));
        }
      } catch (e, stack) {
        lastResponse = ServiceResponse.fromException(e, stack);
        if (attempt < retryConfig.maxAttempts - 1) {
          await Future.delayed(retryConfig.getDelayForAttempt(attempt));
        }
      }
    }

    return lastResponse!;
  }
}

/// Extension methods for ServiceResponse
extension ServiceResponseExtensions<T> on ServiceResponse<T> {
  /// Convert the response to a Future
  Future<T> asFuture() async {
    if (hasError) {
      throw ServiceException(
        errorCode!,
        errorMessage!,
      );
    }
    return data as T;
  }

  /// Apply a transformation if the response is successful
  ServiceResponse<T> apply(void Function(T data) action) {
    if (hasError) return this;
    action(data as T);
    return this;
  }

  /// Log the response result
  ServiceResponse<T> log(void Function(String) logger) {
    if (hasError) {
      logger('Error: [$errorCode] $errorMessage');
    } else {
      logger('Success: $data');
    }
    return this;
  }
}
