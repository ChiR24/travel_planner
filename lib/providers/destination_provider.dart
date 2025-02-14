import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

final destinationServiceProvider = Provider<DestinationService>((ref) {
  return DestinationService();
});

final popularDestinationsProvider =
    FutureProvider<List<Destination>>((ref) async {
  final destinationService = ref.watch(destinationServiceProvider);
  return destinationService.getPopularDestinations();
});

final destinationDetailsProvider =
    FutureProvider.family<Destination, String>((ref, id) async {
  final destinationService = ref.watch(destinationServiceProvider);
  return destinationService.getDestinationDetails(id);
});
