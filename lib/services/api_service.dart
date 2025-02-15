import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import '../config/api_config.dart';
import 'base_service.dart';
import 'base_service_response.dart';

class ApiService implements BaseService {
  final http.Client _client;
  bool _isInitialized = false;

  ApiService([http.Client? client]) : _client = client ?? http.Client();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<BaseServiceResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParameters,
      );

      final response = await retry(
        () => _client.get(
          uri,
          headers: {
            ...ApiConfig.defaultHeaders,
            ...?headers,
          },
        ).timeout(const Duration(seconds: ApiConfig.timeout)),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
        maxAttempts: ApiConfig.maxRetries,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (fromJson != null) {
          final data = fromJson(jsonData);
          return BaseServiceResponse.success(data);
        }
        return BaseServiceResponse.success(jsonData as T);
      }

      return BaseServiceResponse.error(
        'API Error: ${response.statusCode}',
        code: response.statusCode,
      );
    } catch (e) {
      return BaseServiceResponse.error('Network Error: $e');
    }
  }

  Future<BaseServiceResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await retry(
        () => _client
            .post(
              uri,
              headers: {
                ...ApiConfig.defaultHeaders,
                ...?headers,
              },
              body: json.encode(body),
            )
            .timeout(const Duration(seconds: ApiConfig.timeout)),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
        maxAttempts: ApiConfig.maxRetries,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (fromJson != null) {
          final data = fromJson(jsonData);
          return BaseServiceResponse.success(data);
        }
        return BaseServiceResponse.success(jsonData as T);
      }

      return BaseServiceResponse.error(
        'API Error: ${response.statusCode}',
        code: response.statusCode,
      );
    } catch (e) {
      return BaseServiceResponse.error('Network Error: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _client.close();
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> reset() async {
    dispose();
    _isInitialized = false;
    await initialize();
  }

  @override
  String get serviceName => 'ApiService';
}
