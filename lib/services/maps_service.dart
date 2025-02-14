import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MapsService {
  final String _apiKey;
  final String _baseUrl = 'https://maps.googleapis.com/maps/api';
  final Map<String, LatLng> _locationCache = {};

  MapsService(this._apiKey);

  Future<LatLng> getLocationCoordinates(String address) async {
    // Check cache first
    if (_locationCache.containsKey(address)) {
      return _locationCache[address]!;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final latLng = LatLng(location['lat'], location['lng']);

          // Cache the result
          _locationCache[address] = latLng;
          return latLng;
        }
      }
      throw Exception('Failed to get location coordinates');
    } catch (e) {
      throw Exception('Error getting location coordinates: $e');
    }
  }

  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/directions/json?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = _decodePolyline(
            data['routes'][0]['overview_polyline']['points'],
          );
          return points;
        }
      }
      throw Exception('Failed to get route points');
    } catch (e) {
      throw Exception('Error getting route points: $e');
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
  }
}
