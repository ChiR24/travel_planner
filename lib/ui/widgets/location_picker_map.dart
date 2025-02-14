import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationPickerMap extends ConsumerStatefulWidget {
  final void Function(LatLng) onLocationPicked;
  final String title;
  final LatLng? initialLocation;

  const LocationPickerMap({
    super.key,
    required this.onLocationPicked,
    required this.title,
    this.initialLocation,
  });

  @override
  ConsumerState<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends ConsumerState<LocationPickerMap> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    if (_selectedLocation != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation!,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
            widget.onLocationPicked(newPosition);
          },
        ),
      };
    } else {
      _markers = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.initialLocation ??
                      const LatLng(51.5074, -0.1278), // Default to London
                  zoom: 13,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                },
                markers: _markers,
                onTap: (position) {
                  setState(() {
                    _selectedLocation = position;
                    _updateMarkers();
                  });
                  widget.onLocationPicked(position);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
              ),
              if (_selectedLocation == null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Tap on the map to select a location',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
