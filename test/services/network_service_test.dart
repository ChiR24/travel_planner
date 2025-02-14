import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:travel_planner_2/services/network_service.dart';
import 'package:travel_planner_2/services/logger_service.dart';

class MockDio extends Mock implements Dio {}

class MockLoggerService extends Mock implements LoggerService {}

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

class MockResponse extends Mock implements Response {}

class MockDioError extends Mock implements DioException {}

void main() {
  late NetworkService networkService;
  late MockDio mockDio;
  late MockLoggerService mockLogger;
  late MockInternetConnectionChecker mockConnectionChecker;

  setUp(() {
    mockDio = MockDio();
    mockLogger = MockLoggerService();
    mockConnectionChecker = MockInternetConnectionChecker();

    networkService = NetworkService(
      dio: mockDio,
      logger: mockLogger,
      connectionChecker: mockConnectionChecker,
      timeout: const Duration(seconds: 30),
      maxRetries: 3,
    );

    // Default successful connection
    when(() => mockConnectionChecker.hasConnection)
        .thenAnswer((_) async => true);
  });

  group('NetworkService - GET requests', () {
    const path = '/test';
    final queryParams = {'key': 'value'};
    final headers = {'Authorization': 'Bearer token'};

    test('successful GET request', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'data': 'test'});

      when(() => mockDio.get(
            path,
            queryParameters: queryParams,
            options: any(named: 'options'),
          )).thenAnswer((_) async => mockResponse);

      final result = await networkService.get<Map<String, dynamic>>(
        path: path,
        queryParameters: queryParams,
        headers: headers,
      );

      expect(result, {'data': 'test'});
      verify(() => mockLogger.logRequest(any(), any(), headers: headers))
          .called(1);
      verify(() => mockLogger.logResponse(any(), any(), 200, any())).called(1);
    });

    test('GET request with no internet connection', () async {
      when(() => mockConnectionChecker.hasConnection)
          .thenAnswer((_) async => false);

      expect(
        () => networkService.get(path: path),
        throwsA(isA<NetworkException>().having(
          (e) => e.message,
          'message',
          'No internet connection',
        )),
      );
    });

    test('GET request with retry on timeout', () async {
      final mockError = MockDioError();
      when(() => mockError.type).thenReturn(DioExceptionType.connectionTimeout);

      when(() => mockDio.get(
            path,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => throw mockError);

      expect(
        () => networkService.get(path: path),
        throwsA(isA<NetworkException>()),
      );

      // Verify retry attempts
      verify(() => mockDio.get(
            path,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(3); // maxRetries = 3
    });

    test('GET request with parser', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'id': 1, 'name': 'Test'});

      when(() => mockDio.get(
            path,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => mockResponse);

      final result = await networkService.get<TestModel>(
        path: path,
        parser: (data) => TestModel.fromJson(data as Map<String, dynamic>),
      );

      expect(result, isA<TestModel>());
      expect(result.id, 1);
      expect(result.name, 'Test');
    });
  });

  group('NetworkService - POST requests', () {
    const path = '/test';
    final data = {'test': 'data'};

    test('successful POST request', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(201);
      when(() => mockResponse.data).thenReturn({'id': 1});

      when(() => mockDio.post(
            path,
            data: data,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => mockResponse);

      final result = await networkService.post<Map<String, dynamic>>(
        path: path,
        data: data,
      );

      expect(result, {'id': 1});
      verify(() => mockLogger.logRequest(any(), any(),
          headers: any(named: 'headers'))).called(1);
      verify(() => mockLogger.logResponse(any(), any(), 201, any())).called(1);
    });

    test('POST request with server error', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(() => mockResponse.data).thenReturn({'error': 'Server error'});

      when(() => mockDio.post(
            path,
            data: data,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => mockResponse);

      expect(
        () => networkService.post(path: path, data: data),
        throwsA(isA<NetworkException>().having(
          (e) => e.statusCode,
          'statusCode',
          500,
        )),
      );
    });
  });

  group('NetworkService - Error handling', () {
    test('handles connection timeout', () async {
      final mockError = MockDioError();
      when(() => mockError.type).thenReturn(DioExceptionType.connectionTimeout);
      when(() => mockError.message).thenReturn('Connection timeout');

      when(() => mockDio.get(any())).thenAnswer((_) async => throw mockError);

      expect(
        () => networkService.get(path: '/test'),
        throwsA(isA<NetworkException>().having(
          (e) => e.message,
          'message',
          'Connection timed out',
        )),
      );
    });

    test('handles invalid response format', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn('invalid json');

      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      expect(
        () => networkService.getObject<TestModel>(
          path: '/test',
          fromJson: TestModel.fromJson,
        ),
        throwsA(isA<NetworkException>().having(
          (e) => e.message,
          'message',
          'Expected object response',
        )),
      );
    });
  });
}

class TestModel {
  final int id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
