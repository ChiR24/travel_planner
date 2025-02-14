import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/maps_service.dart';
import 'config_provider.dart';

final mapsServiceProvider = Provider<MapsService>((ref) {
  final googleMapsApiKey = ref.watch(googleMapsApiKeyProvider).when(
        data: (key) => key ?? '',
        loading: () => '',
        error: (_, __) => '',
      );
  return MapsService(googleMapsApiKey);
});

// Provider for location coordinates
final locationCoordinatesProvider =
    FutureProvider.family<LatLng, String>((ref, address) async {
  final mapsService = ref.watch(mapsServiceProvider);
  return mapsService.getLocationCoordinates(address);
});

// Provider for route points
final routePointsProvider =
    FutureProvider.family<List<LatLng>, ({LatLng origin, LatLng destination})>(
        (ref, params) async {
  final mapsService = ref.watch(mapsServiceProvider);
  return mapsService.getRoutePoints(params.origin, params.destination);
});

// Provider for route markers
final routeMarkersProvider = Provider.family<Set<Marker>,
    List<({String id, String title, LatLng position})>>((ref, locations) {
  final mapsService = ref.watch(mapsServiceProvider);
  return locations
      .map((loc) => Marker(
            markerId: MarkerId(loc.id),
            position: loc.position,
            infoWindow: InfoWindow(title: loc.title),
          ))
      .toSet();
});
