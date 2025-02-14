import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_picker_map.dart';

class LocationPickerDialog extends ConsumerWidget {
  final String title;
  final LatLng? initialLocation;

  const LocationPickerDialog({
    super.key,
    required this.title,
    this.initialLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LatLng? selectedLocation;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: LocationPickerMap(
                title: title,
                initialLocation: initialLocation,
                onLocationPicked: (location) {
                  selectedLocation = location;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (selectedLocation != null) {
                      Navigator.pop(context, selectedLocation);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a location on the map'),
                        ),
                      );
                    }
                  },
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
