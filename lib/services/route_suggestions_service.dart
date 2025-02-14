import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteSuggestionsService {
  final String _geminiApiKey;
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _cacheExpiration = Duration(minutes: 30);

  // Cache for suggestions with expiration
  final Map<String, _CacheEntry> _cache = {};

  RouteSuggestionsService(this._geminiApiKey);

  Future<Map<String, dynamic>> getSuggestions({
    required String startLocation,
    required String destination,
    required Map<String, dynamic> routeInfo,
  }) async {
    if (_geminiApiKey.isEmpty) {
      throw const RouteServiceException('Gemini API key not configured');
    }

    // Create cache key
    final cacheKey = '${startLocation}_$destination';

    // Check cache first and validate expiration
    final cacheEntry = _cache[cacheKey];
    if (cacheEntry != null && !cacheEntry.isExpired) {
      return cacheEntry.data;
    }

    String? lastResponse;

    try {
      final result = await _retryWithDelay(0, () async {
        final response = await http
            .post(
              Uri.parse('$baseUrl?key=$_geminiApiKey'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {
                        'text':
                            _buildPrompt(startLocation, destination, routeInfo)
                      }
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.7,
                  'topK': 40,
                  'topP': 0.95,
                  'maxOutputTokens': 8192,
                },
              }),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          var generatedText = _extractGeneratedText(data);
          lastResponse = generatedText;

          final jsonData = _parseAndValidateResponse(generatedText);

          // Cache the successful response with expiration
          _cache[cacheKey] = _CacheEntry(
            data: jsonData,
            timestamp: DateTime.now(),
          );

          return jsonData;
        }

        _handleErrorResponse(response);
        throw RouteServiceException('Failed to get suggestions');
      });

      return result;
    } catch (e) {
      if (e is RouteServiceException) rethrow;
      throw RouteServiceException('Failed to get suggestions: ${e.toString()}');
    }
  }

  String _extractGeneratedText(Map<String, dynamic> data) {
    try {
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (e) {
      throw const RouteServiceException('Invalid API response format');
    }
  }

  Map<String, dynamic> _parseAndValidateResponse(String generatedText) {
    // Remove any markdown formatting
    final cleanText =
        generatedText.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      final jsonData = jsonDecode(cleanText);
      if (!_validateResponse(jsonData)) {
        throw const RouteServiceException('Invalid response structure');
      }
      return jsonData;
    } catch (e) {
      throw RouteServiceException(
          'Failed to parse response: ${e.toString()}\nRaw: $cleanText');
    }
  }

  void _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 429:
        throw const RouteServiceException('Rate limit exceeded');
      case 401:
        throw const RouteServiceException('Invalid API key');
      case 403:
        throw const RouteServiceException('Access forbidden');
      default:
        throw RouteServiceException(
            'Server error: ${response.statusCode} - ${response.body}');
    }
  }

  String _buildPrompt(String startLocation, String destination,
      Map<String, dynamic> routeInfo) {
    return '''
You are an expert travel and weather advisor. Analyze this route and provide comprehensive travel suggestions:

Route Details:
- Start Location: ${routeInfo['startAddress'] ?? startLocation}
- Destination: ${routeInfo['endAddress'] ?? destination}
- Distance: ${routeInfo['distance'] ?? 'Not available'}
- Duration: ${routeInfo['duration'] ?? 'Not available'}

Please provide a detailed analysis in the following JSON format:
{
  "travelTips": [
    {
      "category": "Best Time",
      "suggestion": "Recommended time to start the journey considering traffic patterns, weather, and local events"
    },
    {
      "category": "Route Tips",
      "suggestion": "Specific advice about the route including alternative routes, shortcuts, and scenic detours"
    },
    {
      "category": "Stops",
      "suggestion": "Recommended rest stops, points of interest, and emergency services along the route"
    },
    {
      "category": "Safety",
      "suggestion": "Safety considerations including road conditions, areas to avoid, and emergency preparedness"
    },
    {
      "category": "Local Insights",
      "suggestion": "Cultural tips, local customs, and insider advice for both locations"
    }
  ],
  "routeHighlights": [
    "Notable locations, landmarks, and attractions along the route that shouldn't be missed"
  ],
  "weatherConsideration": {
    "startLocation": {
      "forecast": "Detailed weather forecast for the starting location",
      "recommendations": "Weather-specific travel advice and preparations"
    },
    "destination": {
      "forecast": "Detailed weather forecast for the destination",
      "recommendations": "Weather-specific travel advice and preparations"
    },
    "enRoute": "Weather conditions and considerations along the route"
  },
  "trafficTips": {
    "peakHours": "Known peak traffic hours and congestion patterns",
    "avoidance": "Areas or times to avoid",
    "alternatives": "Alternative routes during heavy traffic"
  }
}

Focus on providing accurate, actionable information that will help travelers make informed decisions. Include seasonal considerations, local events, and practical advice. Return ONLY valid JSON without any markdown formatting or additional text.''';
  }

  bool _validateResponse(Map<String, dynamic> response) {
    try {
      // Check for required fields
      if (!response.containsKey('travelTips') ||
          !response.containsKey('weatherConsideration') ||
          !response.containsKey('trafficTips')) {
        return false;
      }

      // Validate travel tips
      final tips = response['travelTips'];
      if (tips is! List || tips.isEmpty) {
        return false;
      }

      // Validate weather consideration structure
      final weather = response['weatherConsideration'];
      if (weather is! Map<String, dynamic> ||
          !weather.containsKey('startLocation') ||
          !weather.containsKey('destination')) {
        return false;
      }

      // Validate startLocation and destination in weather
      final startLocation = weather['startLocation'];
      final destination = weather['destination'];
      if (startLocation is! Map<String, dynamic> ||
          destination is! Map<String, dynamic> ||
          !startLocation.containsKey('forecast') ||
          !startLocation.containsKey('recommendations') ||
          !destination.containsKey('forecast') ||
          !destination.containsKey('recommendations')) {
        return false;
      }

      // Validate traffic tips structure
      final traffic = response['trafficTips'];
      if (traffic is! Map<String, dynamic> ||
          !traffic.containsKey('peakHours') ||
          !traffic.containsKey('avoidance') ||
          !traffic.containsKey('alternatives')) {
        return false;
      }

      return true;
    } catch (e) {
      print('Validation error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _retryWithDelay(
    int attempt,
    Future<Map<String, dynamic>> Function() operation,
  ) async {
    try {
      if (attempt > 0) {
        print(
            'Retrying suggestion request (attempt ${attempt + 1}/$_maxRetries)');
        await Future.delayed(_retryDelay * attempt);
      }
      return await operation();
    } catch (e) {
      if (attempt == _maxRetries - 1) {
        rethrow;
      }
      print('Attempt ${attempt + 1} failed: $e');
      return await _retryWithDelay(attempt + 1, operation);
    }
  }

  // Clear cache for testing or when needed
  void clearCache() {
    _cache.clear();
  }
}

class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CacheEntry({
    required this.data,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) >
      RouteSuggestionsService._cacheExpiration;
}

class RouteServiceException implements Exception {
  final String message;
  const RouteServiceException(this.message);

  @override
  String toString() => message;
}
