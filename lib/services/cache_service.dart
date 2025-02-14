import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';

class CacheService {
  final SharedPreferences _prefs;
  static const String _itineraryPrefix = 'itinerary_';
  static const String _weatherPrefix = 'weather_';
  static const Duration _itineraryCacheDuration = Duration(days: 7);
  static const Duration _weatherCacheDuration = Duration(hours: 6);

  CacheService(this._prefs);

  Future<void> cacheItinerary(Itinerary itinerary) async {
    final key = _getItineraryKey(itinerary);
    final data = {
      'itinerary': itinerary.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(key, jsonEncode(data));
  }

  Future<Itinerary?> getCachedItinerary({
    required String origin,
    required List<String> destinations,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> preferences,
  }) async {
    final key = _getItineraryKey(
      Itinerary(
        id: '',
        origin: origin,
        destinations: destinations,
        startDate: startDate,
        endDate: endDate,
        preferences: preferences,
        days: [],
      ),
    );

    final cachedData = _prefs.getString(key);
    if (cachedData == null) return null;

    final data = jsonDecode(cachedData);
    final timestamp = DateTime.parse(data['timestamp']);
    if (DateTime.now().difference(timestamp) > _itineraryCacheDuration) {
      await _prefs.remove(key);
      return null;
    }

    return Itinerary.fromJson(data['itinerary']);
  }

  Future<void> cacheWeather(
      String location, Map<String, dynamic> weatherData) async {
    final key = '$_weatherPrefix$location';
    final data = {
      'weather': weatherData,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getCachedWeather(String location) async {
    final key = '$_weatherPrefix$location';
    final cachedData = _prefs.getString(key);
    if (cachedData == null) return null;

    final data = jsonDecode(cachedData);
    final timestamp = DateTime.parse(data['timestamp']);
    if (DateTime.now().difference(timestamp) > _weatherCacheDuration) {
      await _prefs.remove(key);
      return null;
    }

    return data['weather'];
  }

  String _getItineraryKey(Itinerary itinerary) {
    final keyComponents = [
      itinerary.origin,
      ...itinerary.destinations,
      itinerary.startDate.toIso8601String(),
      itinerary.endDate.toIso8601String(),
      itinerary.preferences.toString(),
    ];
    return '$_itineraryPrefix${keyComponents.join('_')}';
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_itineraryPrefix) || key.startsWith(_weatherPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
