import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/itinerary.dart';
import 'base_service.dart';

class TripManagementService implements BaseService {
  late Box<String> _tripsBox;
  late Box<String> _templatesBox;
  late Box<String> _archiveBox;
  bool _isInitialized = false;

  static const String _tripsBoxName = 'trips';
  static const String _templatesBoxName = 'trip_templates';
  static const String _archiveBoxName = 'archived_trips';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ensure boxes are closed before opening them again
      if (Hive.isBoxOpen(_tripsBoxName)) await Hive.box(_tripsBoxName).close();
      if (Hive.isBoxOpen(_templatesBoxName))
        await Hive.box(_templatesBoxName).close();
      if (Hive.isBoxOpen(_archiveBoxName))
        await Hive.box(_archiveBoxName).close();

      // Open boxes with retry mechanism
      _tripsBox = await _openBoxWithRetry<String>(_tripsBoxName);
      _templatesBox = await _openBoxWithRetry<String>(_templatesBoxName);
      _archiveBox = await _openBoxWithRetry<String>(_archiveBoxName);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TripManagementService: $e');
      rethrow;
    }
  }

  Future<Box<T>> _openBoxWithRetry<T>(String boxName,
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          return Hive.box<T>(boxName);
        }
        return await Hive.openBox<T>(boxName);
      } catch (e) {
        attempts++;
        if (attempts == maxRetries) {
          throw Exception(
              'Failed to open box $boxName after $maxRetries attempts: $e');
        }
        // Wait before retrying
        await Future.delayed(Duration(milliseconds: 200 * attempts));
      }
    }
    throw Exception('Failed to open box $boxName');
  }

  // Trip Templates
  Future<void> saveTemplate(Itinerary template) async {
    try {
      final jsonString = jsonEncode(template.toJson());
      await _templatesBox.put(template.id, jsonString);
    } catch (e) {
      print('Error saving template: $e');
      rethrow;
    }
  }

  Future<List<Itinerary>> getTemplates() async {
    try {
      return _templatesBox.values.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return Itinerary.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error getting templates: $e');
      return [];
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      await _templatesBox.delete(templateId);
    } catch (e) {
      print('Error deleting template: $e');
      rethrow;
    }
  }

  // Trip Archive
  Future<void> archiveTrip(Itinerary trip) async {
    try {
      // Remove from active trips
      await _tripsBox.delete(trip.id);
      // Add to archive
      final jsonString = jsonEncode(trip.toJson());
      await _archiveBox.put(trip.id, jsonString);
    } catch (e) {
      print('Error archiving trip: $e');
      rethrow;
    }
  }

  Future<void> unarchiveTrip(String tripId) async {
    try {
      final tripJsonString = await _archiveBox.get(tripId);
      if (tripJsonString != null) {
        // Remove from archive
        await _archiveBox.delete(tripId);
        // Add back to active trips
        await _tripsBox.put(tripId, tripJsonString);
      }
    } catch (e) {
      print('Error unarchiving trip: $e');
      rethrow;
    }
  }

  Future<List<Itinerary>> getArchivedTrips() async {
    try {
      return _archiveBox.values.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return Itinerary.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error getting archived trips: $e');
      return [];
    }
  }

  // Trip Statistics
  Future<Map<String, dynamic>> getTripStatistics() async {
    final trips = await getTrips();
    final archivedTrips = await getArchivedTrips();
    final allTrips = [...trips, ...archivedTrips];

    return {
      'totalTrips': allTrips.length,
      'activeTrips': trips.length,
      'archivedTrips': archivedTrips.length,
      'totalDestinations': _calculateTotalDestinations(allTrips),
      'averageTripDuration': _calculateAverageDuration(allTrips),
      'mostVisitedDestinations': _getMostVisitedDestinations(allTrips),
      'upcomingTrips':
          trips.where((trip) => trip.startDate.isAfter(DateTime.now())).length,
      'completedTrips': archivedTrips.length,
      'totalTripDays': _calculateTotalTripDays(allTrips),
    };
  }

  int _calculateTotalDestinations(List<Itinerary> trips) {
    final uniqueDestinations = <String>{};
    for (final trip in trips) {
      uniqueDestinations.addAll(trip.destinations);
    }
    return uniqueDestinations.length;
  }

  Duration _calculateAverageDuration(List<Itinerary> trips) {
    if (trips.isEmpty) return Duration.zero;
    final totalDuration = trips.fold<Duration>(
      Duration.zero,
      (sum, trip) => sum + trip.duration,
    );
    return Duration(days: totalDuration.inDays ~/ trips.length);
  }

  Map<String, int> _getMostVisitedDestinations(List<Itinerary> trips) {
    final destinationCounts = <String, int>{};
    for (final trip in trips) {
      for (final destination in trip.destinations) {
        destinationCounts[destination] =
            (destinationCounts[destination] ?? 0) + 1;
      }
    }
    return Map.fromEntries(
      destinationCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  int _calculateTotalTripDays(List<Itinerary> trips) {
    return trips.fold<int>(
      0,
      (sum, trip) => sum + trip.duration.inDays,
    );
  }

  // Active Trips
  Future<List<Itinerary>> getTrips() async {
    try {
      return _tripsBox.values.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return Itinerary.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error getting trips: $e');
      return [];
    }
  }

  Future<void> saveTrip(Itinerary trip) async {
    try {
      final jsonString = jsonEncode(trip.toJson());
      await _tripsBox.put(trip.id, jsonString);
    } catch (e) {
      print('Error saving trip: $e');
      rethrow;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsBox.delete(tripId);
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _tripsBox.close();
    await _templatesBox.close();
    await _archiveBox.close();
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> reset() async {
    await _tripsBox.clear();
    await _templatesBox.clear();
    await _archiveBox.clear();
  }

  @override
  String get serviceName => 'TripManagementService';
}
