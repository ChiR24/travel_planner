import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/itinerary.dart';
import 'api_service.dart';

class ItineraryService {
  final ApiService _apiService;
  final String _geminiApiKey;
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
  final _uuid = const Uuid();
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  ItineraryService({
    ApiService? apiService,
    required String geminiApiKey,
  })  : _apiService = apiService ?? ApiService(),
        _geminiApiKey = geminiApiKey;

  Future<Itinerary> generateItinerary({
    required String origin,
    required List<String> destinations,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> preferences,
  }) async {
    if (_geminiApiKey.isEmpty) {
      throw Exception(
          'Gemini API key not configured. Please check your configuration.');
    }

    final durationInDays = endDate.difference(startDate).inDays + 1;
    final selectedPreferences = preferences.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .join(', ');

    final prompt = '''
You are an expert travel planner with deep knowledge of global destinations, local cultures, and travel logistics.
Create a detailed, personalized travel itinerary with the following specifications:

Trip Details:
- Origin: $origin
- Destinations: ${destinations.join(' -> ')}
- Duration: $durationInDays days (${startDate.toIso8601String()} to ${endDate.toIso8601String()})
- Traveler Preferences: $selectedPreferences

Consider these factors:
1. Local Events: Include any special events, festivals, or seasonal activities during the travel dates
2. Cultural Context: Consider cultural norms, customs, and etiquette specific to each location
3. Logistics: Account for realistic travel times, jet lag, and transportation between locations
4. Local Specialties: Recommend authentic local cuisine and dining experiences
5. Hidden Gems: Mix popular attractions with lesser-known local favorites
6. Weather: Consider typical weather patterns for the dates and suggest appropriate activities
7. Accessibility: Ensure activities are logically sequenced and geographically sensible
8. Pacing: Balance active periods with rest, especially after long travel segments

Please provide the itinerary in this exact JSON format:
{
  "days": [
    {
      "location": "City Name",
      "activities": [
        {
          "name": "Activity Name",
          "description": "Detailed description including specific venue names, cultural context, practical tips, and why this activity is recommended",
          "startTime": "ISO 8601 datetime",
          "endTime": "ISO 8601 datetime"
        }
      ]
    }
  ]
}

Additional Requirements:
- Include specific venue names, addresses, and landmarks
- Provide practical tips within activity descriptions (e.g., best photo spots, skip-the-line advice)
- Consider opening hours and seasonal availability
- Suggest backup activities or indoor alternatives where relevant
- Include local transportation recommendations
- Note any required advance bookings or reservations
- Add cultural context and historical significance where relevant

Return ONLY valid JSON without any markdown formatting or additional text.''';

    Exception? lastError;
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          print(
              'Retrying API call (attempt ${attempt + 1} of $_maxRetries)...');
          await Future.delayed(_retryDelay * attempt);
        }

        final response = await http.post(
          Uri.parse('$baseUrl?key=$_geminiApiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
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
        );

        if (response.statusCode == 429) {
          // Rate limit exceeded
          print('Rate limit exceeded, waiting before retry...');
          lastError = Exception('Rate limit exceeded');
          continue;
        }

        if (response.statusCode != 200) {
          final errorBody = _parseErrorBody(response.body);
          throw Exception('Failed to generate itinerary: $errorBody');
        }

        final data = jsonDecode(response.body);
        var generatedText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Remove markdown code block markers if present
        generatedText = generatedText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        try {
          // First try to parse the response as is
          final jsonData = jsonDecode(generatedText);
          return Itinerary(
            id: _uuid.v4(),
            origin: origin,
            destinations: destinations,
            startDate: startDate,
            endDate: endDate,
            preferences: preferences,
            days: (jsonData['days'] as List<dynamic>)
                .map((day) => Day.fromJson(day as Map<String, dynamic>))
                .toList(),
          );
        } catch (e) {
          print('Initial JSON parsing failed: $e');

          // Try to fix common JSON issues
          try {
            // If the JSON is truncated, try to find the last complete activity
            if (generatedText.contains('"days"')) {
              final daysMatch = RegExp(r'"days"\s*:\s*\[(.*?)\]', dotAll: true)
                  .firstMatch(generatedText);
              if (daysMatch != null) {
                final daysContent = daysMatch.group(1)!;
                final fixedJson = '{"days": [$daysContent]}';

                try {
                  final jsonData = jsonDecode(fixedJson);
                  return Itinerary(
                    id: _uuid.v4(),
                    origin: origin,
                    destinations: destinations,
                    startDate: startDate,
                    endDate: endDate,
                    preferences: preferences,
                    days: (jsonData['days'] as List<dynamic>)
                        .map((day) => Day.fromJson(day as Map<String, dynamic>))
                        .toList(),
                  );
                } catch (e) {
                  print('Failed to parse fixed JSON: $e');
                }
              }
            }
          } catch (e) {
            print('Error while trying to fix JSON: $e');
          }

          print('Raw response: $generatedText');
          throw Exception(
              'Failed to parse generated itinerary. The AI response was not in the expected format. Error: $e');
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (attempt == _maxRetries - 1) {
          print('All retry attempts failed');
          throw Exception(
              'Failed to generate itinerary after $_maxRetries attempts: ${lastError.toString()}');
        }
      }
    }

    throw lastError ?? Exception('Unknown error occurred');
  }

  String _parseErrorBody(String body) {
    try {
      final data = jsonDecode(body);
      if (data['error'] != null) {
        return data['error']['message'] ?? body;
      }
    } catch (_) {}
    return body;
  }
}
