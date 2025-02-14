import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/route_suggestions_provider.dart';

class RoutePlannerScreen extends ConsumerStatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  ConsumerState<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends ConsumerState<RoutePlannerScreen> {
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();
  Map<String, dynamic>? routeInfo;
  bool isLoading = false;

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _calculateRoute() async {
    if (_startController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both start and destination locations'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      routeInfo = {
        'distance': 'Calculating...',
        'duration': 'Calculating...',
        'startAddress': _startController.text,
        'endAddress': _destinationController.text,
      };
    });

    // Simulate route calculation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
      routeInfo = {
        'distance': 'Distance will be calculated by the actual service',
        'duration': 'Duration will be calculated by the actual service',
        'startAddress': _startController.text,
        'endAddress': _destinationController.text,
      };
    });
  }

  Widget _buildSuggestions() {
    if (_startController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        routeInfo == null) {
      return const SizedBox.shrink();
    }

    final suggestionsAsync = ref.watch(routeSuggestionsProvider((
      startLocation: _startController.text,
      destination: _destinationController.text,
      routeInfo: routeInfo!,
    )));

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions['error'] != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error getting suggestions: ${suggestions['error']}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Travel Suggestions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (suggestions['travelTips'] != null) ...[
                  const Text(
                    'Travel Tips',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.from(suggestions['travelTips']).map((tip) => ListTile(
                        leading: const Icon(Icons.tips_and_updates),
                        title: Text(tip['category']),
                        subtitle: Text(tip['suggestion']),
                      )),
                  const Divider(),
                ],
                if (suggestions['routeHighlights'] != null) ...[
                  const Text(
                    'Route Highlights',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.from(suggestions['routeHighlights'])
                      .map((highlight) => ListTile(
                            leading: const Icon(Icons.star_outline),
                            title: Text(highlight),
                          )),
                  const Divider(),
                ],
                if (suggestions['weatherConsideration'] != null) ...[
                  ListTile(
                    leading: const Icon(Icons.wb_sunny),
                    title: const Text('Weather Consideration'),
                    subtitle: Text(suggestions['weatherConsideration']),
                  ),
                  const Divider(),
                ],
                if (suggestions['trafficTips'] != null)
                  ListTile(
                    leading: const Icon(Icons.traffic),
                    title: const Text('Traffic Tips'),
                    subtitle: Text(suggestions['trafficTips']),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Planner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        labelText: 'Start Location',
                        hintText: 'Enter start location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'Enter destination',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _calculateRoute,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Calculate Route'),
            ),
            if (routeInfo != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (routeInfo!['error'] != null)
                        Text(
                          'Error: ${routeInfo!['error']}',
                          style: const TextStyle(color: Colors.red),
                        )
                      else ...[
                        Text('Distance: ${routeInfo!['distance']}'),
                        Text('Duration: ${routeInfo!['duration']}'),
                        Text('Start: ${routeInfo!['startAddress']}'),
                        Text('End: ${routeInfo!['endAddress']}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSuggestions(),
            ],
          ],
        ),
      ),
    );
  }
}
