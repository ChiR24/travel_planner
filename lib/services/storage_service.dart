import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';

class StorageService {
  static const String _itinerariesKey = 'itineraries';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<List<Itinerary>> loadItineraries() async {
    try {
      final jsonString = _prefs.getString(_itinerariesKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Itinerary.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading itineraries: $e');
      return [];
    }
  }

  Future<void> saveItineraries(List<Itinerary> itineraries) async {
    try {
      final jsonString =
          jsonEncode(itineraries.map((i) => i.toJson()).toList());
      await _prefs.setString(_itinerariesKey, jsonString);
    } catch (e) {
      print('Error saving itineraries: $e');
      rethrow;
    }
  }

  Future<void> clearItineraries() async {
    try {
      await _prefs.remove(_itinerariesKey);
    } catch (e) {
      print('Error clearing itineraries: $e');
      rethrow;
    }
  }
}
