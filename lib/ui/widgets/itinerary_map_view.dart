import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/itinerary.dart';

class ItineraryMapView extends ConsumerStatefulWidget {
  final Itinerary itinerary;
  final List<LatLng> routePoints;

  const ItineraryMapView({
    super.key,
    required this.itinerary,
    required this.routePoints,
  });

  @override
  ConsumerState<ItineraryMapView> createState() => _ItineraryMapViewState();
}

class _ItineraryMapViewState extends ConsumerState<ItineraryMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() {
    // Create markers for each destination
    _markers = widget.routePoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final isOrigin = index == 0;
      final isDestination = index == widget.routePoints.length - 1;

      return Marker(
        markerId: MarkerId('destination_$index'),
        position: point,
        infoWindow: InfoWindow(
          title: isOrigin
              ? widget.itinerary.origin
              : widget.itinerary.destinations[index - 1],
          snippet: isOrigin
              ? 'Starting Point'
              : isDestination
                  ? 'Final Destination'
                  : 'Stop $index',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isOrigin
              ? BitmapDescriptor.hueGreen
              : isDestination
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();

    // Create polyline for the route
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routePoints,
        color: Colors.blue,
        width: 3,
      ),
    };
  }

  void _fitBounds() {
    if (_mapController == null || widget.routePoints.isEmpty) return;

    double minLat = widget.routePoints.first.latitude;
    double maxLat = widget.routePoints.first.latitude;
    double minLng = widget.routePoints.first.longitude;
    double maxLng = widget.routePoints.first.longitude;

    for (var point in widget.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.routePoints.first,
                zoom: 10,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBounds();
              },
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.small(
                onPressed: _fitBounds,
                child: const Icon(Icons.center_focus_strong),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
