import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:travel_planner_2/services/route_suggestions_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late RouteSuggestionsService service;
  late MockHttpClient mockHttpClient;
  const testApiKey = 'test_api_key';

  setUp(() {
    mockHttpClient = MockHttpClient();
    service = RouteSuggestionsService(testApiKey);
  });

  group('getSuggestions', () {
    const startLocation = 'New York';
    const destination = 'London';
    final routeInfo = {
      'startAddress': 'New York, NY, USA',
      'endAddress': 'London, UK',
      'distance': '5,567 km',
      'duration': '7 hours',
    };

    test('returns suggestions when API call is successful', () async {
      final expectedResponse = {
        'travelTips': [
          {
            'category': 'Best Time',
            'suggestion': 'Early morning departure recommended'
          }
        ],
        'weatherConsideration': {
          'startLocation': {
            'forecast': 'Sunny',
            'recommendations': 'Bring sunscreen'
          },
          'destination': {
            'forecast': 'Rainy',
            'recommendations': 'Pack an umbrella'
          }
        },
        'trafficTips': {
          'peakHours': '8-10 AM',
          'avoidance': 'City center during rush hour',
          'alternatives': 'Take the tunnel instead of bridge'
        }
      };

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            '{"candidates": [{"content": {"parts": [{"text": ${expectedResponse.toString()}}]}}]}',
            200,
          ));

      final result = await service.getSuggestions(
        startLocation: startLocation,
        destination: destination,
        routeInfo: routeInfo,
      );

      expect(result, equals(expectedResponse));
      verify(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('throws exception when API key is not configured', () async {
      service = RouteSuggestionsService('');

      expect(
        () => service.getSuggestions(
          startLocation: startLocation,
          destination: destination,
          routeInfo: routeInfo,
        ),
        throwsA(isA<RouteServiceException>()),
      );
    });

    test('retries on rate limit error', () async {
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Rate limit exceeded', 429));

      expect(
        () => service.getSuggestions(
          startLocation: startLocation,
          destination: destination,
          routeInfo: routeInfo,
        ),
        throwsA(isA<RouteServiceException>()),
      );

      verify(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(3); // Verifies 3 retry attempts
    });

    test('validates response structure', () async {
      final invalidResponse = {
        'travelTips': [], // Empty tips list
        'weatherConsideration': {
          'startLocation': {
            'forecast': 'Sunny',
            // Missing recommendations
          },
        },
        // Missing trafficTips
      };

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            '{"candidates": [{"content": {"parts": [{"text": ${invalidResponse.toString()}}]}}]}',
            200,
          ));

      expect(
        () => service.getSuggestions(
          startLocation: startLocation,
          destination: destination,
          routeInfo: routeInfo,
        ),
        throwsA(isA<RouteServiceException>()),
      );
    });

    test('uses cache when available and not expired', () async {
      final cachedResponse = {
        'travelTips': [
          {
            'category': 'Cached Tip',
            'suggestion': 'This is a cached suggestion'
          }
        ],
        'weatherConsideration': {
          'startLocation': {
            'forecast': 'Cached weather',
            'recommendations': 'Cached recommendation'
          },
          'destination': {
            'forecast': 'Cached weather',
            'recommendations': 'Cached recommendation'
          }
        },
        'trafficTips': {
          'peakHours': 'Cached hours',
          'avoidance': 'Cached avoidance',
          'alternatives': 'Cached alternatives'
        }
      };

      // First call to populate cache
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            '{"candidates": [{"content": {"parts": [{"text": ${cachedResponse.toString()}}]}}]}',
            200,
          ));

      await service.getSuggestions(
        startLocation: startLocation,
        destination: destination,
        routeInfo: routeInfo,
      );

      // Second call should use cache
      final result = await service.getSuggestions(
        startLocation: startLocation,
        destination: destination,
        routeInfo: routeInfo,
      );

      expect(result, equals(cachedResponse));
      verify(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1); // Verifies only one API call was made
    });
  });
}
