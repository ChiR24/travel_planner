import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../../core/utils/app_error_handler.dart';
import '../../../../models/activity.dart';

/// A widget that displays a map with activities.
class OfflineMapView extends ConsumerStatefulWidget {
  final List<Activity> activities;
  final String destination;
  final Function(Activity) onActivityTap;

  const OfflineMapView({
    Key? key,
    required this.activities,
    required this.destination,
    required this.onActivityTap,
  }) : super(key: key);

  @override
  ConsumerState<OfflineMapView> createState() => _OfflineMapViewState();
}

class _OfflineMapViewState extends ConsumerState<OfflineMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isMapInitialized = false;
  bool _isOfflineMapAvailable = false;
  String _offlineMapPath = '';

  @override
  void initState() {
    super.initState();
    _checkOfflineMapStatus();
    _createMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _checkOfflineMapStatus() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final mapFileName =
          'map_${widget.destination.replaceAll(' ', '_').toLowerCase()}.png';
      _offlineMapPath = '${appDir.path}/$mapFileName';

      final file = File(_offlineMapPath);
      _isOfflineMapAvailable = await file.exists();

      setState(() {});
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e);
      }
    }
  }

  Future<void> _createMarkers() async {
    final markers = <Marker>{};

    for (final activity in widget.activities) {
      if (activity.latitude != null && activity.longitude != null) {
        final marker = Marker(
          markerId: MarkerId(activity.id ?? activity.name),
          position: LatLng(activity.latitude!, activity.longitude!),
          infoWindow: InfoWindow(
            title: activity.name,
            snippet: activity.description,
            onTap: () => widget.onActivityTap(activity),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(activity.category.toString()),
          ),
        );

        markers.add(marker);
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerHue(String category) {
    switch (category.toLowerCase()) {
      case 'dining':
        return BitmapDescriptor.hueOrange;
      case 'sightseeing':
        return BitmapDescriptor.hueAzure;
      case 'entertainment':
        return BitmapDescriptor.hueViolet;
      case 'shopping':
        return BitmapDescriptor.hueRose;
      case 'nature':
        return BitmapDescriptor.hueGreen;
      case 'transportation':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapInitialized = true;
    });

    if (_markers.isNotEmpty) {
      _fitBounds();
    }

    if (!_isOfflineMapAvailable) {
      _showDownloadMapDialog();
    }
  }

  Future<void> _fitBounds() async {
    if (_mapController == null || _markers.isEmpty) return;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    // Add padding to the bounds
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  Future<void> _captureMapForOfflineUse() async {
    try {
      if (_mapController == null) return;

      // Show progress indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving map for offline use...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Capture the map as an image
      final Uint8List? imageBytes = await _mapController!.takeSnapshot();

      if (imageBytes != null) {
        // Save the image to the app's documents directory
        final file = File(_offlineMapPath);
        await file.writeAsBytes(imageBytes);

        setState(() {
          _isOfflineMapAvailable = true;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Map saved for offline use!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e);
      }
    }
  }

  void _showDownloadMapDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Map for Offline Use'),
        content: const Text(
          'Would you like to save this map for offline use? '
          'This will allow you to view the map without an internet connection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Thanks'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _captureMapForOfflineUse();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we have an offline map and no internet connection, show the offline map
    if (_isOfflineMapAvailable && File(_offlineMapPath).existsSync()) {
      return Stack(
        children: [
          Image.file(
            File(_offlineMapPath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Offline Map',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Otherwise, show the Google Map
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0), // Will be updated once map is loaded
              zoom: 1,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
          ),
        ),
        if (_isMapInitialized && !_isOfflineMapAvailable)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _captureMapForOfflineUse,
              icon: const Icon(Icons.download),
              label: const Text('Save Map for Offline Use'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
      ],
    );
  }
}
