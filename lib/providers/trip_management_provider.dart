import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../services/trip_management_service.dart';

final tripManagementServiceProvider = Provider<TripManagementService>((ref) {
  final service = TripManagementService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for active trips
final activeTripsProvider = FutureProvider<List<Itinerary>>((ref) async {
  final service = ref.watch(tripManagementServiceProvider);
  return service.getTrips();
});

// Provider for archived trips
final archivedTripsProvider = FutureProvider<List<Itinerary>>((ref) async {
  final service = ref.watch(tripManagementServiceProvider);
  return service.getArchivedTrips();
});

// Provider for trip templates
final tripTemplatesProvider = FutureProvider<List<Itinerary>>((ref) async {
  final service = ref.watch(tripManagementServiceProvider);
  return service.getTemplates();
});

// Provider for trip statistics
final tripStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(tripManagementServiceProvider);
  return service.getTripStatistics();
});

// Provider for trip actions
class TripActionsNotifier extends StateNotifier<void> {
  final TripManagementService _service;

  TripActionsNotifier(this._service) : super(null);

  Future<void> saveTrip(Itinerary trip) async {
    await _service.saveTrip(trip);
  }

  Future<void> deleteTrip(String tripId) async {
    await _service.deleteTrip(tripId);
  }

  Future<void> archiveTrip(Itinerary trip) async {
    await _service.archiveTrip(trip);
  }

  Future<void> unarchiveTrip(String tripId) async {
    await _service.unarchiveTrip(tripId);
  }

  Future<void> saveTemplate(Itinerary template) async {
    await _service.saveTemplate(template);
  }

  Future<void> deleteTemplate(String templateId) async {
    await _service.deleteTemplate(templateId);
  }
}

final tripActionsProvider =
    StateNotifierProvider<TripActionsNotifier, void>((ref) {
  final service = ref.watch(tripManagementServiceProvider);
  return TripActionsNotifier(service);
});
