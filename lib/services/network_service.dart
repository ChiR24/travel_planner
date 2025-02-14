import 'dart:async';
import 'package:dio/dio.dart';
import 'package:retry/retry.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../services/logger_service.dart';

class NetworkService {
  final Dio _dio;
  final LoggerService _logger;
  final InternetConnectionChecker _connectionChecker;
  final Duration _timeout;
  final int _maxRetries;

  NetworkService({
    Dio? dio,
    LoggerService? logger,
    InternetConnectionChecker? connectionChecker,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
  })  : _dio = dio ?? Dio(),
        _logger = logger ?? LoggerService(),
        _connectionChecker = connectionChecker ?? InternetConnectionChecker(),
        _timeout = timeout,
        _maxRetries = maxRetries {
    _setupDio();
  }

  void _setupDio() {
    _dio.options
      ..baseUrl = 'https://api.example.com/v1'
      ..connectTimeout = _timeout
      ..receiveTimeout = _timeout
      ..sendTimeout = _timeout
      ..validateStatus = (status) => status != null && status < 500;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _logger.logRequest(
      options.method,
      options.uri.toString(),
      headers: options.headers,
    );
    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.logResponse(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      response.statusCode ?? -1,
      response.data,
    );
    handler.next(response);
  }

  void _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    _logger.e(
      'Network Error: ${error.message}',
      error,
      error.stackTrace,
    );
    handler.next(error);
  }

  Future<bool> get hasInternetConnection => _connectionChecker.hasConnection;

  Stream<bool> get onConnectivityChanged => _connectionChecker.onStatusChange
      .map((status) => status == InternetConnectionStatus.connected);

  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      parser: parser,
    );
  }

  Future<T> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      parser: parser,
    );
  }

  Future<T> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      parser: parser,
    );
  }

  Future<T> delete<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.delete(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      parser: parser,
    );
  }

  Future<T> _executeWithRetry<T>(
    Future<Response> Function() request, {
    T Function(dynamic)? parser,
  }) async {
    if (!await hasInternetConnection) {
      throw NetworkException('No internet connection');
    }

    try {
      final response = await retry(
        () async {
          try {
            return await request();
          } on DioException catch (e) {
            if (_shouldRetry(e)) {
              rethrow;
            } else {
              throw NetworkException.fromDioError(e);
            }
          }
        },
        retryIf: (e) => e is DioException && _shouldRetry(e),
        maxAttempts: _maxRetries,
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        throw NetworkException(
          'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      if (parser != null) {
        return parser(response.data);
      }

      return response.data as T;
    } on NetworkException {
      rethrow;
    } catch (e, stack) {
      _logger.e('Unexpected network error', e, stack);
      throw NetworkException('Unexpected error occurred');
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  void dispose() {
    _dio.close();
  }
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  NetworkException(
    this.message, {
    this.statusCode,
    this.data,
  });

  factory NetworkException.fromDioError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out';
        break;
      case DioExceptionType.badResponse:
        message = 'Server error: ${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      default:
        message = 'Network error occurred';
    }

    return NetworkException(
      message,
      statusCode: error.response?.statusCode,
      data: error.response?.data,
    );
  }

  @override
  String toString() => message;
}

// Extension for easy access to network service
extension NetworkServiceExtension on NetworkService {
  Future<List<T>> getList<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return get<List<T>>(
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      parser: (data) {
        if (data is! List) {
          throw NetworkException('Expected list response');
        }
        return data
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<T> getObject<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return get<T>(
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw NetworkException('Expected object response');
        }
        return fromJson(data);
      },
    );
  }
}
