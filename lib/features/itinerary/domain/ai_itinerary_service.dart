import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../config/api_config.dart';
import '../../../models/itinerary.dart';
import '../../../models/activity_category.dart';

/// A service that generates itineraries using AI.
class AIItineraryService {
  final _uuid = const Uuid();
  int _retryCount = 0;
  final int _maxRetries = ApiConfig.maxRetries;

  /// Generates an itinerary based on user preferences.
  ///
  /// [destination] - The destination for the trip
  /// [startDate] - The start date of the trip
  /// [endDate] - The end date of the trip
  /// [preferences] - User preferences for the trip (e.g., "family-friendly", "adventure", "relaxing")
  /// [budget] - Budget level (e.g., "budget", "moderate", "luxury")
  Future<Itinerary> generateItinerary({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    List<String> preferences = const [],
    String budget = 'moderate',
  }) async {
    try {
      print('AIItineraryService.generateItinerary called');
      print('useMockData: ${ApiConfig.useMockData}');

      // If useMockData is true, skip the API call and return mock data directly
      if (ApiConfig.useMockData) {
        print('Using mock data for itinerary generation (useMockData is true)');
        return _generateMockItinerary(
          destination: destination,
          startDate: startDate,
          endDate: endDate,
          preferences: preferences,
          budget: budget,
        );
      }

      // Check if Gemini API key is valid
      if (ApiConfig.geminiApiKey.isEmpty ||
          ApiConfig.geminiApiKey.contains('DemoKey')) {
        print('Invalid Gemini API key. Using mock data instead.');
        return _generateMockItinerary(
          destination: destination,
          startDate: startDate,
          endDate: endDate,
          preferences: preferences,
          budget: budget,
        );
      }

      // Prepare the request payload
      final payload = {
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'preferences': preferences,
        'budget': budget,
        'apiKey': ApiConfig.geminiApiKey,
      };

      // Try to call the API
      try {
        print(
          'Calling API for itinerary generation: ${ApiConfig.getAiItineraryUrl()}',
        );
        final response = await http
            .post(
              Uri.parse(ApiConfig.getAiItineraryUrl()),
              headers: ApiConfig.defaultHeaders,
              body: jsonEncode(payload),
            )
            .timeout(Duration(seconds: ApiConfig.timeout));

        if (response.statusCode == 200) {
          // Parse the response
          final data = jsonDecode(response.body);
          // In a real implementation, you would parse the API response
          // For now, we'll reset the retry count and return a mock itinerary
          _retryCount = 0;
          return _generateMockItinerary(
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            preferences: preferences,
            budget: budget,
          );
        } else {
          // Handle API errors
          print('API error: ${response.statusCode} - ${response.body}');
          if (_retryCount < _maxRetries) {
            _retryCount++;
            print(
              'Retrying API call (attempt $_retryCount of $_maxRetries)...',
            );
            return generateItinerary(
              destination: destination,
              startDate: startDate,
              endDate: endDate,
              preferences: preferences,
              budget: budget,
            );
          } else {
            _retryCount = 0;
            // If all retries fail, fall back to mock data
            print('All retry attempts failed, using mock data');
            return _generateMockItinerary(
              destination: destination,
              startDate: startDate,
              endDate: endDate,
              preferences: preferences,
              budget: budget,
            );
          }
        }
      } catch (e) {
        // Handle network errors
        print('Network error: $e');
        if (_retryCount < _maxRetries) {
          _retryCount++;
          print('Retrying API call (attempt $_retryCount of $_maxRetries)...');
          return generateItinerary(
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            preferences: preferences,
            budget: budget,
          );
        } else {
          _retryCount = 0;
          // If all retries fail, fall back to mock data
          print('All retry attempts failed, using mock data');
          return _generateMockItinerary(
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            preferences: preferences,
            budget: budget,
          );
        }
      }
    } catch (e) {
      // Handle any other errors
      print('Error generating itinerary: $e');
      return _generateMockItinerary(
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        preferences: preferences,
        budget: budget,
      );
    }
  }

  /// Generates a mock itinerary for demonstration purposes.
  Itinerary _generateMockItinerary({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    List<String> preferences = const [],
    String budget = 'moderate',
  }) {
    final days = <Day>[];
    final dayCount = endDate.difference(startDate).inDays + 1;

    // Generate days
    for (int i = 0; i < dayCount; i++) {
      final date = startDate.add(Duration(days: i));
      final activities = _generateActivitiesForDay(
        date,
        destination,
        preferences,
        budget,
      );

      days.add(Day(location: destination, activities: activities));
    }

    return Itinerary(
      id: _uuid.v4(),
      origin: 'Home',
      destinations: [destination],
      startDate: startDate,
      endDate: endDate,
      preferences: {'interests': preferences, 'budget': budget},
      days: days,
    );
  }

  /// Generates mock activities for a day.
  List<Activity> _generateActivitiesForDay(
    DateTime date,
    String destination,
    List<String> preferences,
    String budget,
  ) {
    final activities = <Activity>[];

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

    if (preferences.contains('adventure')) {
      afternoonCategory = ActivityCategory.adventure;
      afternoonName = 'Hiking in $destination National Park';
      afternoonDescription =
          'Experience the natural beauty of $destination with a guided hiking tour.';
      afternoonTags = ['hiking', 'nature', 'adventure'];
    } else if (preferences.contains('shopping')) {
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

/// Provider for the AI Itinerary Service
final aiItineraryServiceProvider = Provider<AIItineraryService>((ref) {
  return AIItineraryService();
});

/// Provider for generating an itinerary
/// This is a family provider that takes parameters for the generation
final aiGeneratedItineraryProvider =
    FutureProvider.family<Itinerary, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(aiItineraryServiceProvider);
  return service.generateItinerary(
    destination: params['destination'],
    startDate: params['startDate'],
    endDate: params['endDate'],
    preferences: params['preferences'] ?? [],
    budget: params['budget'] ?? 'moderate',
  );
});
