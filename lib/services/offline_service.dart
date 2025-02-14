import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/itinerary.dart';

class OfflineService {
  static const String _itinerariesBox = 'itineraries';
  static const String _routeSuggestionsBox = 'routeSuggestions';
  static const Duration _cacheValidity = Duration(days: 7);

  late Box<String> _itinerariesCache;
  late Box<String> _suggestionsCache;
  final Connectivity _connectivity = Connectivity();

  Future<void> initialize() async {
    await Hive.initFlutter();
    _itinerariesCache = await Hive.openBox<String>(_itinerariesBox);
    _suggestionsCache = await Hive.openBox<String>(_routeSuggestionsBox);
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> cacheItinerary(Itinerary itinerary) async {
    final cacheEntry = CacheEntry(
      data: itinerary.toJson(),
      timestamp: DateTime.now(),
    );
    await _itinerariesCache.put(
      itinerary.id,
      cacheEntry.toJson(),
    );
  }

  Future<Itinerary?> getCachedItinerary(String id) async {
    final cachedData = _itinerariesCache.get(id);
    if (cachedData == null) return null;

    final cacheEntry = CacheEntry.fromJson(cachedData);
    if (DateTime.now().difference(cacheEntry.timestamp) > _cacheValidity) {
      await _itinerariesCache.delete(id);
      return null;
    }

    return Itinerary.fromJson(cacheEntry.data);
  }

  Future<void> cacheRouteSuggestions(
    String key,
    Map<String, dynamic> suggestions,
  ) async {
    final cacheEntry = CacheEntry(
      data: suggestions,
      timestamp: DateTime.now(),
    );
    await _suggestionsCache.put(key, cacheEntry.toJson());
  }

  Future<Map<String, dynamic>?> getCachedRouteSuggestions(String key) async {
    final cachedData = _suggestionsCache.get(key);
    if (cachedData == null) return null;

    final cacheEntry = CacheEntry.fromJson(cachedData);
    if (DateTime.now().difference(cacheEntry.timestamp) > _cacheValidity) {
      await _suggestionsCache.delete(key);
      return null;
    }

    return cacheEntry.data;
  }

  Future<void> clearCache() async {
    await _itinerariesCache.clear();
    await _suggestionsCache.clear();
  }

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}

class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  CacheEntry({
    required this.data,
    required this.timestamp,
  });

  String toJson() =>
      '{"data": ${data.toString()}, "timestamp": "${timestamp.toIso8601String()}"}';

  factory CacheEntry.fromJson(String json) {
    final map = Map<String, dynamic>.from(json as Map);
    return CacheEntry(
      data: map['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
