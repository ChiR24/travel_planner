# Travel Planner Services Documentation

## Overview
This document provides detailed information about the services used in the Travel Planner application.

## Table of Contents
1. [Network Service](#network-service)
2. [Performance Service](#performance-service)
3. [Logger Service](#logger-service)
4. [Analytics Service](#analytics-service)
5. [Security Service](#security-service)
6. [Cache Service](#cache-service)
7. [Localization Service](#localization-service)
8. [Configuration Service](#configuration-service)

## Network Service
The `NetworkService` handles all HTTP communication in the application.

### Features
- Automatic retry mechanism for failed requests
- Internet connectivity checking
- Request/response interceptors
- Error handling
- Response parsing
- Request timeout management

### Usage
```dart
final networkService = NetworkService();

// GET request
final data = await networkService.get<Map<String, dynamic>>(
  path: '/api/endpoint',
  queryParameters: {'key': 'value'},
  headers: {'Authorization': 'Bearer token'},
);

// POST request with parsing
final user = await networkService.post<User>(
  path: '/api/users',
  data: {'name': 'John'},
  parser: (json) => User.fromJson(json),
);

// Using extensions
final users = await networkService.getList<User>(
  path: '/api/users',
  fromJson: User.fromJson,
);
```

## Performance Service
The `PerformanceService` tracks application performance metrics.

### Features
- Operation timing
- HTTP request tracking
- Frame rendering metrics
- Memory usage monitoring
- Custom trace tracking

### Usage
```dart
final performanceService = PerformanceService();

// Track operation
final result = await performanceService.trackOperation(
  name: 'operation_name',
  operation: () => someAsyncOperation(),
  attributes: {'type': 'database'},
);

// Track HTTP request
final response = await performanceService.trackHttpRequest(
  url: 'https://api.example.com',
  method: 'GET',
  request: () => http.get(url),
);

// Track UI operation
await performanceService.trackUiOperation(
  name: 'screen_load',
  operation: () => loadScreenData(),
);
```

## Logger Service
The `LoggerService` provides centralized logging functionality.

### Features
- Multiple log levels (verbose, debug, info, warning, error)
- Crashlytics integration
- Device info logging
- Performance logging
- Network request logging

### Usage
```dart
final logger = LoggerService();

// Log levels
logger.v('Verbose message');
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error, stackTrace);

// Performance logging
logger.logPerformance('operation', duration);

// Network logging
logger.logRequest('GET', 'https://api.example.com');
logger.logResponse('GET', 'https://api.example.com', 200, response);
```

## Analytics Service
The `AnalyticsService` tracks user behavior and app usage.

### Features
- Screen view tracking
- User action tracking
- Custom event logging
- User property tracking
- Session tracking

### Usage
```dart
final analytics = AnalyticsService();

// Track screen view
await analytics.trackScreenView('HomeScreen');

// Track user action
await analytics.trackUserAction('button_click', {
  'button_id': 'submit',
  'screen': 'login',
});

// Track custom event
await analytics.logEvent(
  name: 'item_selected',
  parameters: {'item_id': '123'},
);
```

## Security Service
The `SecurityService` handles security-related functionality.

### Features
- API key management
- Data encryption/decryption
- Token management
- Input sanitization
- Password hashing

### Usage
```dart
final security = SecurityService();

// Store API key
await security.storeApiKey('service_name', 'api_key');

// Get API key
final apiKey = await security.getApiKey('service_name');

// Encrypt data
final encrypted = security.encryptData('sensitive data');

// Verify password
final isValid = security.verifyPassword(
  password,
  hashedPassword,
);
```

## Cache Service
The `CacheService` manages data caching.

### Features
- In-memory caching
- Persistent storage
- Cache expiration
- Cache size management
- Automatic cleanup

### Usage
```dart
final cache = CacheService();

// Store data
await cache.set('key', data, duration: Duration(hours: 1));

// Retrieve data
final data = await cache.get<Map<String, dynamic>>('key');

// Clear cache
await cache.clear();
```

## Localization Service
The `LocalizationService` handles multi-language support.

### Features
- Multiple language support
- Dynamic language switching
- Fallback translations
- Locale management
- Translation caching

### Usage
```dart
final localization = LocalizationService();

// Get translation
final text = localization.translate('key');

// Change language
await localization.setLanguage('es');

// Get current locale
final locale = localization.locale;
```

## Configuration Service
The `AppConfigService` manages application configuration.

### Features
- Environment-based configuration
- Feature flags
- Theme configuration
- API settings
- Performance settings

### Usage
```dart
final config = AppConfigService();

// Get configuration
final apiUrl = config.apiBaseUrl;
final timeout = config.apiTimeout;

// Update configuration
await config.updateConfig({
  'theme': {'mode': 'dark'},
});

// Check feature flag
final isEnabled = config.isFeatureEnabled('feature_name');
```

## Best Practices
1. Always dispose services when they're no longer needed
2. Use dependency injection for better testability
3. Handle errors appropriately
4. Log important events and errors
5. Monitor performance metrics
6. Keep sensitive data secure
7. Cache data when appropriate
8. Use proper error boundaries
9. Follow the principle of least privilege
10. Keep services single-responsibility

## Error Handling
All services implement proper error handling:
- Network errors are wrapped in `NetworkException`
- Cache errors are wrapped in `CacheException`
- Security errors are wrapped in `SecurityException`
- Configuration errors are wrapped in `ConfigException`

Example:
```dart
try {
  await networkService.get('/api/data');
} on NetworkException catch (e) {
  logger.e('Network error', e);
  // Handle error appropriately
} catch (e, stack) {
  logger.e('Unexpected error', e, stack);
  // Handle unexpected errors
}
```

## Testing
All services have corresponding test files:
- Unit tests for business logic
- Integration tests for service interactions
- Mock implementations for testing
- Performance benchmarks

Example:
```dart
test('NetworkService - retry on timeout', () async {
  final service = NetworkService(
    dio: mockDio,
    maxRetries: 3,
  );
  
  when(() => mockDio.get(any()))
    .thenThrow(TimeoutException('Timeout'));
    
  expect(
    () => service.get(path: '/test'),
    throwsA(isA<NetworkException>()),
  );
  
  verify(() => mockDio.get(any())).called(3);
});
```

## Error Codes and Responses
All services use standardized error codes and response formats:

### Error Codes
```dart
enum ServiceErrorCode {
  // General Errors (1000-1999)
  UNKNOWN_ERROR = 1000,
  INITIALIZATION_FAILED = 1001,
  INVALID_CONFIGURATION = 1002,
  SERVICE_UNAVAILABLE = 1003,
  
  // Network Errors (2000-2999)
  NETWORK_UNAVAILABLE = 2000,
  REQUEST_TIMEOUT = 2001,
  INVALID_RESPONSE = 2002,
  API_ERROR = 2003,
  
  // Cache Errors (3000-3999)
  CACHE_MISS = 3000,
  CACHE_WRITE_ERROR = 3001,
  CACHE_READ_ERROR = 3002,
  CACHE_EXPIRED = 3003,
  
  // Security Errors (4000-4999)
  UNAUTHORIZED = 4000,
  INVALID_TOKEN = 4001,
  ENCRYPTION_ERROR = 4002,
  DECRYPTION_ERROR = 4003,
  
  // Data Errors (5000-5999)
  INVALID_DATA = 5000,
  DATA_NOT_FOUND = 5001,
  VALIDATION_ERROR = 5002,
  PARSING_ERROR = 5003,
}
```

### Standard Response Format
```dart
class ServiceResponse<T> {
  final bool success;
  final T? data;
  final ServiceErrorCode? errorCode;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  ServiceResponse({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasError => !success;
  bool get hasData => data != null;
}
```

### Service Method Documentation

#### NetworkService
```dart
/// Performs a GET request with automatic retries and error handling
/// 
/// Parameters:
/// - path: The API endpoint path
/// - queryParameters: Optional query parameters
/// - headers: Optional request headers
/// - parser: Optional response parser function
/// 
/// Returns:
/// - ServiceResponse<T> with parsed data or error information
/// 
/// Throws:
/// - NetworkException for unrecoverable network errors
/// - ServiceException for service-level errors
Future<ServiceResponse<T>> get<T>({
  required String path,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
  T Function(dynamic)? parser,
});
```

#### CacheService
```dart
/// Stores data in the cache with expiration
/// 
/// Parameters:
/// - key: Unique identifier for the cached data
/// - data: Data to be cached
/// - duration: Optional cache duration (defaults to 1 hour)
/// 
/// Returns:
/// - ServiceResponse<void> indicating success or failure
/// 
/// Throws:
/// - CacheException for storage-related errors
Future<ServiceResponse<void>> set<T>(
  String key,
  T data, {
  Duration? duration,
});
```

#### SecurityService
```dart
/// Encrypts sensitive data using the configured encryption algorithm
/// 
/// Parameters:
/// - data: Data to be encrypted
/// - options: Optional encryption options
/// 
/// Returns:
/// - ServiceResponse<String> with encrypted data or error information
/// 
/// Throws:
/// - SecurityException for encryption-related errors
Future<ServiceResponse<String>> encryptData(
  String data, {
  EncryptionOptions? options,
});
```

### Best Practices for Error Handling

1. **Consistent Error Propagation**
```dart
try {
  final result = await service.operation();
  if (result.hasError) {
    logger.e('Operation failed', result.errorCode, result.errorMessage);
    // Handle specific error codes
    switch (result.errorCode) {
      case ServiceErrorCode.NETWORK_UNAVAILABLE:
        // Handle network error
        break;
      case ServiceErrorCode.UNAUTHORIZED:
        // Handle authentication error
        break;
      default:
        // Handle unknown error
    }
  }
} on ServiceException catch (e) {
  // Handle service-specific exceptions
} catch (e, stack) {
  // Handle unexpected errors
}
```

2. **Retry Strategies**
```dart
/// Retry configuration for different error scenarios
final retryConfig = {
  ServiceErrorCode.NETWORK_UNAVAILABLE: RetryConfig(
    maxAttempts: 3,
    delay: Duration(seconds: 1),
    exponential: true,
  ),
  ServiceErrorCode.REQUEST_TIMEOUT: RetryConfig(
    maxAttempts: 2,
    delay: Duration(seconds: 2),
  ),
};
```

3. **Error Recovery**
```dart
/// Error recovery strategies for different scenarios
final recoveryStrategies = {
  ServiceErrorCode.CACHE_EXPIRED: () async {
    // Clear expired cache and fetch fresh data
    await cacheService.clear();
    return networkService.fetchFreshData();
  },
  ServiceErrorCode.INVALID_TOKEN: () async {
    // Refresh authentication token
    await securityService.refreshToken();
    return retryOperation();
  },
};
```

### Performance Monitoring

Each service includes built-in performance monitoring:

```dart
class ServiceMetrics {
  final String operation;
  final Duration duration;
  final bool success;
  final ServiceErrorCode? errorCode;
  final Map<String, dynamic> attributes;
  
  // Additional metrics
  final int? memoryUsage;
  final int? networkBytes;
  final int? cacheHits;
}
```

Example usage:
```dart
final metrics = await performanceService.trackOperation(
  'fetch_user_data',
  () => userService.fetchUserData(userId),
  attributes: {
    'user_id': userId,
    'include_details': true,
  },
);

logger.i('Operation completed', {
  'duration_ms': metrics.duration.inMilliseconds,
  'success': metrics.success,
  'memory_mb': metrics.memoryUsage! / (1024 * 1024),
});
```

### Service Dependencies

Services can declare their dependencies for proper initialization order:

```dart
final serviceDependencies = {
  NetworkService: [],
  LoggerService: [],
  CacheService: [NetworkService],
  SecurityService: [LoggerService],
  AnalyticsService: [NetworkService, LoggerService],
  UserService: [SecurityService, CacheService],
};
```

This ensures services are initialized in the correct order and dependencies are available when needed.

### Service Configuration

Each service supports runtime configuration updates:

```dart
final config = {
  'network': {
    'timeout': Duration(seconds: 30),
    'retryAttempts': 3,
    'baseUrl': 'https://api.example.com',
  },
  'cache': {
    'maxSize': 100 * 1024 * 1024, // 100MB
    'defaultExpiration': Duration(hours: 1),
  },
  'security': {
    'encryptionAlgorithm': 'AES-256',
    'tokenExpiration': Duration(days: 7),
  },
};

await serviceRegistry.updateConfiguration(config);
```

### Service Health Checks

Implement health checks for each service:

```dart
class ServiceHealth {
  final bool isHealthy;
  final String status;
  final Map<String, dynamic> metrics;
  final DateTime lastCheck;
  
  // Additional health indicators
  final double memoryUsage;
  final int activeConnections;
  final int errorRate;
}

// Example health check implementation
Future<ServiceHealth> checkHealth() async {
  final metrics = await collectMetrics();
  return ServiceHealth(
    isHealthy: metrics.errorRate < 0.05,
    status: 'operational',
    metrics: metrics.toJson(),
    lastCheck: DateTime.now(),
    memoryUsage: metrics.memoryUsage,
    activeConnections: metrics.connections,
    errorRate: metrics.errorRate,
  );
}
```

### Service Lifecycle Events

Subscribe to service lifecycle events:

```dart
serviceRegistry.on<NetworkService>().listen((event) {
  switch (event.type) {
    case ServiceEventType.initialized:
      logger.i('Network service initialized');
      break;
    case ServiceEventType.configurationChanged:
      logger.i('Network configuration updated', event.data);
      break;
    case ServiceEventType.error:
      logger.e('Network service error', event.error);
      break;
  }
});
```

These improvements provide:
- Standardized error handling
- Consistent response formats
- Detailed documentation
- Performance monitoring
- Health checks
- Configuration management
- Event handling

Would you like me to implement any of these improvements in specific services? 