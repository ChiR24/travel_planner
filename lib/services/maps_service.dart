import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class MapsService {
  final String _apiKey;
  final String _baseUrl = ApiConfig.googleMapsApiBaseUrl;
  final Map<String, LatLng> _locationCache = {};
  final Map<String, dynamic> _placeDetailsCache = {};

  MapsService({String? apiKey})
      : _apiKey = apiKey ?? ApiConfig.googleMapsApiKey;

  /// Get coordinates for a location by address
  Future<Map<String, dynamic>> getLocationCoordinates(String location) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final location = results[0]['geometry']['location'];
            return {
              'lat': location['lat'],
              'lng': location['lng'],
              'formatted_address': results[0]['formatted_address'],
            };
          }
        } else {
          throw Exception(
              'Google Maps API error: ${data['status']} - ${data['error_message'] ?? ""}');
        }
      }

      throw Exception('Failed to get location coordinates');
    } catch (e) {
      print('Error getting location coordinates for $location: $e');
      rethrow;
    }
  }

  /// Get route points between two locations
  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    try {
      print(
          'Fetching route points from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/directions/json?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] != 'OK') {
          print(
              'Google Maps API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
          throw Exception('Google Maps API error: ${data['status']}');
        }

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = _decodePolyline(
            data['routes'][0]['overview_polyline']['points'],
          );
          return points;
        } else {
          print('No routes found');
          throw Exception('No routes found');
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to get route points: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting route points: $e');
      throw Exception('Error getting route points: $e');
    }
  }

  /// Get travel time and distance between two locations
  Future<Map<String, dynamic>> getTravelInfo(LatLng origin, LatLng destination,
      {String mode = 'driving'}) async {
    try {
      print(
          'Fetching travel info from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/distancematrix/json?origins=${origin.latitude},${origin.longitude}'
          '&destinations=${destination.latitude},${destination.longitude}'
          '&mode=$mode'
          '&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] != 'OK') {
          print(
              'Google Maps API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
          throw Exception('Google Maps API error: ${data['status']}');
        }

        if (data['rows'] != null &&
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          final element = data['rows'][0]['elements'][0];

          if (element['status'] != 'OK') {
            print('Route error: ${element['status']}');
            throw Exception('Route error: ${element['status']}');
          }

          return {
            'distance': element['distance']['text'],
            'distance_value': element['distance']['value'], // in meters
            'duration': element['duration']['text'],
            'duration_value': element['duration']['value'], // in seconds
          };
        } else {
          print('No route elements found');
          throw Exception('No route elements found');
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to get travel information: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting travel information: $e');
      throw Exception('Error getting travel information: $e');
    }
  }

  /// Search for places by query
  Future<List<Map<String, dynamic>>> searchPlaces(String query,
      {LatLng? location, int radius = 50000}) async {
    try {
      String url =
          '$_baseUrl/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_apiKey';

      // Add location bias if provided
      if (location != null) {
        url +=
            '&location=${location.latitude},${location.longitude}&radius=$radius';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
      throw Exception('Failed to search places');
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  /// Get place details by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    // Check cache first
    if (_placeDetailsCache.containsKey(placeId)) {
      return _placeDetailsCache[placeId]!;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/details/json?place_id=$placeId&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null) {
          // Cache the result
          _placeDetailsCache[placeId] = data['result'];
          return data['result'];
        }
      }
      throw Exception('Failed to get place details');
    } catch (e) {
      throw Exception('Error getting place details: $e');
    }
  }

  /// Get nearby places by type
  Future<List<Map<String, dynamic>>> getNearbyPlaces(
      LatLng location, String type,
      {int radius = 5000}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/nearbysearch/json?location=${location.latitude},${location.longitude}'
          '&radius=$radius&type=$type&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
      throw Exception('Failed to get nearby places');
    } catch (e) {
      throw Exception('Error getting nearby places: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  BitmapDescriptor createCustomMarker(Color color) {
    // TODO: Implement custom marker creation
    return BitmapDescriptor.defaultMarkerWithHue(
      color == Colors.red
          ? BitmapDescriptor.hueRed
          : color == Colors.green
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueBlue,
    );
  }

  void clearCache() {
    _locationCache.clear();
    _placeDetailsCache.clear();
  }

  // Map<String, dynamic> _getMockCoordinates(String location) { // removed
    // Predefined coordinates for common locations
    final Map<String, Map<String, dynamic>> knownLocations = {
      'paris': {
        'lat': 48.8566,
        'lng': 2.3522,
        'formatted_address': 'Paris, France'
      },
      'london': {
        'lat': 51.5074,
        'lng': -0.1278,
        'formatted_address': 'London, UK'
      },
      'new york': {
        'lat': 40.7128,
        'lng': -74.0060,
        'formatted_address': 'New York, NY, USA'
      },
      'tokyo': {
        'lat': 35.6762,
        'lng': 139.6503,
        'formatted_address': 'Tokyo, Japan'
      },
      'sydney': {
        'lat': -33.8688,
        'lng': 151.2093,
        'formatted_address': 'Sydney, Australia'
      },
      'rome': {
        'lat': 41.9028,
        'lng': 12.4964,
        'formatted_address': 'Rome, Italy'
      },
      'cairo': {
        'lat': 30.0444,
        'lng': 31.2357,
        'formatted_address': 'Cairo, Egypt'
      },
      'rio de janeiro': {
        'lat': -22.9068,
        'lng': -43.1729,
        'formatted_address': 'Rio de Janeiro, Brazil'
      },
      'dubai': {
        'lat': 25.2048,
        'lng': 55.2708,
        'formatted_address': 'Dubai, UAE'
      },
      'singapore': {
        'lat': 1.3521,
        'lng': 103.8198,
        'formatted_address': 'Singapore'
      },
      'jaipur': {
        'lat': 26.9124,
        'lng': 75.7873,
        'formatted_address': 'Jaipur, Rajasthan, India'
      },
      'agra': {
        'lat': 27.1767,
        'lng': 78.0081,
        'formatted_address': 'Agra, Uttar Pradesh, India'
      },
      'delhi': {
        'lat': 28.7041,
        'lng': 77.1025,
        'formatted_address': 'Delhi, India'
      },
      'mumbai': {
        'lat': 19.0760,
        'lng': 72.8777,
        'formatted_address': 'Mumbai, Maharashtra, India'
      },
    };

    // Try to find the location in our predefined list (case insensitive)
    final normalizedLocation = location.toLowerCase();
    if (knownLocations.containsKey(normalizedLocation)) {
      print('Using predefined coordinates for $location');
      return knownLocations[normalizedLocation]!;
    }

    // Generate random but plausible coordinates if location not found
    print('Generating mock coordinates for unknown location: $location');
    final random = Random();
    return {
      'lat': (random.nextDouble() * 180) - 90, // -90 to 90
      'lng': (random.nextDouble() * 360) - 180, // -180 to 180
      'formatted_address': 'Mock location for $location',
    };
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    try {
      // Use Haversine formula for distance calculation
      const R = 6371.0; // Earth radius in kilometers

      // Convert degrees to radians
      final dLat = _toRadians(lat2 - lat1);
      final dLon = _toRadians(lon2 - lon1);

      // Haversine formula
      final a = sin(dLat / 2) * sin(dLat / 2) +
          cos(_toRadians(lat1)) *
              cos(_toRadians(lat2)) *
              sin(dLon / 2) *
              sin(dLon / 2);

      final c = 2 * asin(sqrt(a));
      final distance = R * c;

      return distance;
    } catch (e) {
      print('Error calculating distance: $e');
      // Return a reasonable default
      return 10.0;
    }
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
