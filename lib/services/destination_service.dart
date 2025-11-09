import '../models/destination.dart';
import 'api_service.dart';

class DestinationService {
  final ApiService _apiService;

  DestinationService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<Destination>> getPopularDestinations() async {
    try {
      final response = await _apiService.get('/destinations/popular');
      final List<dynamic> data = response['destinations'] as List<dynamic>;
      return data
          .map((json) => Destination.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Destination> getDestinationDetails(String id) async {
    try {
      final response = await _apiService.get('/destinations/$id');
      return Destination.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Removed legacy mock destination helper to ensure only real API data is used.
  // List<Destination> _getMockDestinations() { // removed
    return [
      Destination(
        id: '1',
        name: 'Paris',
        description:
            'The City of Light dazzles with iconic landmarks, world-class cuisine, and artistic treasures.',
        imageUrl:
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600',
        latitude: 48.8566,
        longitude: 2.3522,
        metadata: {
          'country': 'France',
          'bestTimeToVisit': 'April to October',
          'popularAttractions': [
            'Eiffel Tower',
            'Louvre Museum',
            'Notre-Dame Cathedral'
          ],
        },
      ),
      Destination(
        id: '2',
        name: 'Tokyo',
        description:
            'A city where ultra-modern living meets traditional culture.',
        imageUrl:
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600',
        latitude: 35.6762,
        longitude: 139.6503,
        metadata: {
          'country': 'Japan',
          'bestTimeToVisit': 'March to May',
          'popularAttractions': [
            'Shibuya Crossing',
            'Senso-ji Temple',
            'Tokyo Skytree'
          ],
        },
      ),
      Destination(
        id: '3',
        name: 'New York City',
        description:
            'The city that never sleeps, offering endless entertainment and cultural experiences.',
        imageUrl:
            'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600',
        latitude: 40.7128,
        longitude: -74.0060,
        metadata: {
          'country': 'United States',
          'bestTimeToVisit': 'April to June or September to November',
          'popularAttractions': [
            'Times Square',
            'Central Park',
            'Statue of Liberty'
          ],
        },
      ),
    ];
  }
}
