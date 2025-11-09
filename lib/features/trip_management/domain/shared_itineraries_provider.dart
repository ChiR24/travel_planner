import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/itinerary.dart';

/// A service for managing shared itineraries.
/// NOTE: Example-only shared itineraries service. Not used in production.
/// To enable, provide a real backend URL and inject auth tokens via a secure provider.
class SharedItinerariesService {
  final String _baseUrl =
      ApiConfig.sharedItinerariesBaseUrl; // Configure real API endpoint via ApiConfig

  /// Fetches shared itineraries for the current user.
  Future<List<Itinerary>> getSharedItineraries() async {
    try {
      // In a real implementation, you would include authentication headers
      final response = await http.get(
        Uri.parse('$_baseUrl/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer TODO_INJECT_AUTH_TOKEN', // placeholder
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Itinerary.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch shared itineraries: ${response.statusCode}');
      }
    } catch (e) {
      // In a real implementation, you might want to log this error
      throw Exception('Error fetching shared itineraries: $e');
    }
  }

  /// Shares an itinerary with other users.
  ///
  /// [itineraryId] - The ID of the itinerary to share
  /// [emails] - List of email addresses to share with
  /// [message] - Optional message to include with the share
  Future<void> shareItinerary({
    required String itineraryId,
    required List<String> emails,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer TODO_INJECT_AUTH_TOKEN', // placeholder
        },
        body: jsonEncode({
          'itineraryId': itineraryId,
          'emails': emails,
          if (message != null) 'message': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to share itinerary: ${response.statusCode}');
      }
    } catch (e) {
      // In a real implementation, you might want to log this error
      throw Exception('Error sharing itinerary: $e');
    }
  }

  /// Removes a shared itinerary.
  ///
  /// [itineraryId] - The ID of the itinerary to unshare
  /// [email] - Email address to remove from sharing
  Future<void> unshareItinerary({
    required String itineraryId,
    required String email,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/unshare'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer TODO_INJECT_AUTH_TOKEN', // placeholder
        },
        body: jsonEncode({
          'itineraryId': itineraryId,
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unshare itinerary: ${response.statusCode}');
      }
    } catch (e) {
      // In a real implementation, you might want to log this error
      throw Exception('Error unsharing itinerary: $e');
    }
  }
}

/// Provider for the Shared Itineraries Service
final sharedItinerariesServiceProvider =
    Provider<SharedItinerariesService>((ref) {
  return SharedItinerariesService();
});

/// Provider for shared itineraries
final sharedItinerariesProvider = FutureProvider<List<Itinerary>>((ref) async {
  final service = ref.watch(sharedItinerariesServiceProvider);
  return service.getSharedItineraries();
});

/// Provider for sharing an itinerary
/// This is a family provider that takes parameters for sharing
final shareItineraryProvider =
    FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final service = ref.watch(sharedItinerariesServiceProvider);
    return service.shareItinerary(
      itineraryId: params['itineraryId'],
      emails: params['emails'],
      message: params['message'],
    );
  },
);
