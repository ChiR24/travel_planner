import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/itinerary.dart';
import '../models/activity_category.dart';
import '../config/api_config.dart';
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
    print('ItineraryService.generateItinerary called');
    print('useMockData: ${ApiConfig.useMockData}');

    // Print the first few characters of the API key for debugging
    String keyPrefix = _geminiApiKey.isNotEmpty
        ? _geminiApiKey.substring(0, math.min(10, _geminiApiKey.length)) + "..."
        : "empty";
    print('Using Gemini API key (prefix): $keyPrefix');

    // Use the API key from ApiConfig if the provided key is empty or invalid
    final String effectiveApiKey =
        (_geminiApiKey.isEmpty || _geminiApiKey.contains('DemoKey'))
            ? ApiConfig.geminiApiKey
            : _geminiApiKey;

    print(
        'Using effective API key (prefix): ${effectiveApiKey.substring(0, math.min(10, effectiveApiKey.length))}...');

    // If useMockData is true, skip the API call and return mock data directly
    if (ApiConfig.useMockData) {
      print('Using mock data for itinerary generation (useMockData is true)');
      return _generateMockItinerary(
        origin: origin,
        destinations: destinations,
        startDate: startDate,
        endDate: endDate,
        preferences: preferences,
      );
    }

    // Check if Gemini API key is valid
    if (effectiveApiKey.isEmpty || effectiveApiKey.contains('DemoKey')) {
      print('Invalid Gemini API key. Using mock data instead.');
      return _generateMockItinerary(
        origin: origin,
        destinations: destinations,
        startDate: startDate,
        endDate: endDate,
        preferences: preferences,
      );
    }

    if (effectiveApiKey.isEmpty) {
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
          Uri.parse('$baseUrl?key=$effectiveApiKey'),
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

  /// Generates a mock itinerary for demonstration purposes.
  Itinerary _generateMockItinerary({
    required String origin,
    required List<String> destinations,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> preferences,
  }) {
    final days = <Day>[];
    final dayCount = endDate.difference(startDate).inDays + 1;
    final destination =
        destinations.isNotEmpty ? destinations.first : 'Unknown';

    // Generate days
    for (int i = 0; i < dayCount; i++) {
      final date = startDate.add(Duration(days: i));
      final activities = _generateActivitiesForDay(
        date,
        destination,
        preferences,
      );

      days.add(Day(location: destination, activities: activities));
    }

    return Itinerary(
      id: _uuid.v4(),
      origin: origin,
      destinations: destinations,
      startDate: startDate,
      endDate: endDate,
      preferences: preferences,
      days: days,
    );
  }

  /// Generates mock activities for a day.
  List<Activity> _generateActivitiesForDay(
    DateTime date,
    String destination,
    Map<String, dynamic> preferences,
  ) {
    final activities = <Activity>[];
    final budget = preferences['budget'] ?? 'moderate';

    // Adjust activity quality based on budget
    String qualityPrefix = '';
    if (budget == 'luxury') {
      qualityPrefix = 'Luxury ';
    } else if (budget == 'budget') {
      qualityPrefix = 'Budget-friendly ';
    }

    // Morning activity
    activities.add(
      Activity(
        name: '${qualityPrefix}Breakfast at Local Cafe',
        description:
            'Start your day with a delicious breakfast at a popular local cafe.',
        startTime: DateTime(date.year, date.month, date.day, 8, 0),
        endTime: DateTime(date.year, date.month, date.day, 9, 30),
        category: ActivityCategory.dining,
        tags: ['breakfast', 'local', 'cafe'],
      ),
    );

    // Late morning activity
    activities.add(
      Activity(
        name: 'Visit $destination Museum',
        description:
            'Explore the cultural heritage of $destination at its famous museum.',
        startTime: DateTime(date.year, date.month, date.day, 10, 0),
        endTime: DateTime(date.year, date.month, date.day, 12, 30),
        category: ActivityCategory.culture,
        tags: ['museum', 'culture', 'history'],
      ),
    );

    // Lunch
    activities.add(
      Activity(
        name: '${qualityPrefix}Lunch at Downtown Restaurant',
        description:
            'Enjoy a delicious lunch at a popular restaurant in downtown $destination.',
        startTime: DateTime(date.year, date.month, date.day, 13, 0),
        endTime: DateTime(date.year, date.month, date.day, 14, 30),
        category: ActivityCategory.dining,
        tags: ['lunch', 'restaurant', 'downtown'],
      ),
    );

    // Afternoon activity
    ActivityCategory afternoonCategory;
    String afternoonName;
    String afternoonDescription;
    List<String> afternoonTags;

    if (preferences['adventure'] == true) {
      afternoonCategory = ActivityCategory.adventure;
      afternoonName = 'Hiking in $destination National Park';
      afternoonDescription =
          'Experience the natural beauty of $destination with a guided hiking tour.';
      afternoonTags = ['hiking', 'nature', 'adventure'];
    } else if (preferences['shopping'] == true) {
      afternoonCategory = ActivityCategory.shopping;
      afternoonName = 'Shopping at $destination Mall';
      afternoonDescription =
          'Explore the best shopping destinations in $destination.';
      afternoonTags = ['shopping', 'mall', 'retail'];
    } else {
      afternoonCategory = ActivityCategory.sightseeing;
      afternoonName = 'City Tour of $destination';
      afternoonDescription =
          'Discover the landmarks and hidden gems of $destination with a guided city tour.';
      afternoonTags = ['tour', 'sightseeing', 'landmarks'];
    }

    activities.add(
      Activity(
        name: afternoonName,
        description: afternoonDescription,
        startTime: DateTime(date.year, date.month, date.day, 15, 0),
        endTime: DateTime(date.year, date.month, date.day, 18, 0),
        category: afternoonCategory,
        tags: afternoonTags,
      ),
    );

    // Evening activity
    activities.add(
      Activity(
        name: '${qualityPrefix}Dinner at $destination Signature Restaurant',
        description:
            'End your day with a memorable dining experience at one of $destination\'s finest restaurants.',
        startTime: DateTime(date.year, date.month, date.day, 19, 0),
        endTime: DateTime(date.year, date.month, date.day, 21, 0),
        category: ActivityCategory.dining,
        tags: ['dinner', 'fine dining', 'local cuisine'],
      ),
    );

    return activities;
  }
}
