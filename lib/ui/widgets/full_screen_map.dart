import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FullScreenMap extends ConsumerWidget {
  final List<String> locations;
  final String title;

  const FullScreenMap({
    super.key,
    required this.locations,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isOrigin = index == 0;
          final isDestination = index == locations.length - 1;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                isOrigin
                    ? Icons.trip_origin
                    : isDestination
                        ? Icons.place
                        : Icons.circle,
                color: isOrigin
                    ? Colors.green
                    : isDestination
                        ? Colors.red
                        : Colors.blue,
              ),
              title: Text(
                location,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                isOrigin
                    ? 'Starting Point'
                    : isDestination
                        ? 'Final Destination'
                        : 'Stop ${index + 1}',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
