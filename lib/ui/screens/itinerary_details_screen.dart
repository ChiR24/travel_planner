import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/itinerary.dart';
import '../../providers/itinerary_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/maps_provider.dart';
import '../widgets/full_screen_map.dart';
import '../widgets/add_expense_dialog.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget.dart' hide Expense;
import '../../models/expense.dart';
import 'expenses_list_screen.dart';

enum ActivityTimeStatus {
  past,
  current,
  upcoming,
  future,
}

class ActivityTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color subtitleColor;
  final Color timeColor;
  final Color accentColor;

  const ActivityTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.subtitleColor,
    required this.timeColor,
    required this.accentColor,
  });
}

class ItineraryDetailsScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const ItineraryDetailsScreen({
    super.key,
    required this.itineraryId,
  });

  @override
  ConsumerState<ItineraryDetailsScreen> createState() =>
      _ItineraryDetailsScreenState();
}

class _ItineraryDetailsScreenState
    extends ConsumerState<ItineraryDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itineraryAsync = ref.watch(itineraryByIdProvider(widget.itineraryId));
    final budgetAsync = ref.watch(budgetProvider(widget.itineraryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Details'),
        actions: [
          if (itineraryAsync != null) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context, itineraryAsync),
              tooltip: 'Search Activities',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _exportItinerary(context, itineraryAsync),
              tooltip: 'Share Itinerary',
            ),
          ],
        ],
      ),
      body: itineraryAsync == null
          ? const Center(child: Text('Itinerary not found'))
          : RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, itineraryAsync),
                    _buildBudgetSection(context, ref, budgetAsync),
                    _buildRouteInfo(context, itineraryAsync),
                    _buildDaysList(context, itineraryAsync),
                  ],
                ),
              ),
            ),
      floatingActionButton: itineraryAsync != null
          ? _buildFloatingActionButton(context, itineraryAsync)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildHeader(BuildContext context, Itinerary itinerary) {
    final dateFormat = DateFormat('MMM d, y');
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip to ${itinerary.destinations.join(', ')}',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormat.format(itinerary.startDate)} - ${dateFormat.format(itinerary.endDate)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 8),
              Text(
                'Starting from ${itinerary.origin}',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context, Itinerary itinerary) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Route Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FullScreenMap(
                              locations: [
                                itinerary.origin,
                                ...itinerary.destinations
                              ],
                              title: 'Route Map',
                            ),
                          ),
                        );
                      },
                      tooltip: 'Full Screen Map',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Consumer(
                      builder: (context, ref, child) {
                        // Get origin coordinates
                        final originCoords = ref.watch(
                          locationCoordinatesProvider(itinerary.origin),
                        );

                        // Get destination coordinates
                        final destinationCoords = ref.watch(
                          locationCoordinatesProvider(
                            itinerary.destinations.last,
                          ),
                        );

                        return originCoords.when(
                          data: (origin) => destinationCoords.when(
                            data: (destination) {
                              // Get route points
                              final routePoints = ref.watch(
                                routePointsProvider((
                                  origin: origin,
                                  destination: destination,
                                )),
                              );

                              // Get markers
                              final markers = ref.watch(routeMarkersProvider([
                                (
                                  id: 'origin',
                                  title: itinerary.origin,
                                  position: origin,
                                ),
                                (
                                  id: 'destination',
                                  title: itinerary.destinations.last,
                                  position: destination,
                                ),
                              ]));

                              return routePoints.when(
                                data: (points) => GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: origin,
                                    zoom: 10,
                                  ),
                                  markers: markers,
                                  polylines: {
                                    Polyline(
                                      polylineId: const PolylineId('route'),
                                      points: points,
                                      color: Colors.blue,
                                      width: 3,
                                    ),
                                  },
                                  mapType: MapType.normal,
                                  myLocationEnabled: true,
                                  zoomControlsEnabled: true,
                                  onMapCreated: (controller) {
                                    _fitMapBounds(controller, points);
                                  },
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, stack) => Center(
                                  child: Text('Error: $error'),
                                ),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Center(
                              child: Text('Error: $error'),
                            ),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Center(
                            child: Text('Error: $error'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From: ${itinerary.origin}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'To: ${itinerary.destinations.last}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (itinerary.destinations.length > 1) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Stops:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...itinerary.destinations
                      .take(itinerary.destinations.length - 1)
                      .map(
                        (stop) => Padding(
                          padding: const EdgeInsets.only(left: 32, bottom: 8),
                          child: Text(
                            '• $stop',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _fitMapBounds(GoogleMapController controller, List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  Widget _buildDaysList(BuildContext context, Itinerary itinerary) {
    final currentDay = DateTime.now().difference(itinerary.startDate).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Daily Schedule',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itinerary.days.length,
          itemBuilder: (context, index) {
            final day = itinerary.days[index];
            final isCurrentDay = index == currentDay;
            final isPastDay = index < currentDay;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                initiallyExpanded: isCurrentDay,
                leading: CircleAvatar(
                  backgroundColor: isCurrentDay
                      ? Theme.of(context).colorScheme.primary
                      : isPastDay
                          ? Colors.grey[300]
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      color: isCurrentDay
                          ? Colors.white
                          : isPastDay
                              ? Colors.grey[600]
                              : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'Day ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  day.location,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
                children: day.activities.map((activity) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    title: Text(
                      activity.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('HH:mm').format(activity.startTime)} - ${DateFormat('HH:mm').format(activity.endTime)}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, Itinerary itinerary) {
    return FloatingActionButton(
      onPressed: () => _showSearchDialog(context, itinerary),
      child: const Icon(Icons.search),
    );
  }

  void _showSearchDialog(BuildContext context, Itinerary itinerary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Search Activities'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or description',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportItinerary(BuildContext context, Itinerary itinerary) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('HH:mm');

    final exportText = '''
🌍 Trip to ${itinerary.destinations.join(', ')}
📅 ${dateFormat.format(itinerary.startDate)} - ${dateFormat.format(itinerary.endDate)}
🏁 Starting from ${itinerary.origin}

${itinerary.days.map((day) => '''
📍 ${day.location}
${day.activities.map((activity) => '''
• ${activity.name}
  ${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}
  ${activity.description}
''').join('\n')}''').join('\n')}

#TravelPlanner
''';
    Share.share(exportText);
  }

  Widget _buildBudgetSection(
    BuildContext context,
    WidgetRef ref,
    Budget? budget,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (budget == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _setupBudget(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Set Up Budget'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showExpensesList(context, budget),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: budget.budgetProgress,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  budget.budgetProgress > 0.9
                      ? Colors.red
                      : budget.budgetProgress > 0.7
                          ? Colors.orange
                          : colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: ${budget.currency} ${budget.totalExpenses.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Total: ${budget.currency} ${budget.totalBudget.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryProgress(context, budget),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _addExpense(context, ref, budget),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(BuildContext context, Budget budget) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: budget.categoryProgress.entries.map((entry) {
        final progress = entry.value;
        final remaining = budget.categoryRemaining[entry.key] ?? 0;
        final isOverBudget = remaining < 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry.key.icon} ${entry.key.label}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${budget.currency} ${remaining.abs().toStringAsFixed(2)} ${isOverBudget ? 'over' : 'left'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 1
                      ? Colors.red
                      : progress > 0.9
                          ? Colors.orange
                          : colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _setupBudget(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Up Budget',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Budget',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Handle budget input
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Currency',
              ),
              items: ['USD', 'EUR', 'GBP', 'JPY']
                  .map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ))
                  .toList(),
              onChanged: (value) {
                // Handle currency selection
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create budget
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(budgetProvider(widget.itineraryId).notifier).createBudget(
            totalBudget: result['totalBudget'] as double,
            currency: result['currency'] as String,
          );
    }
  }

  Future<void> _addExpense(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final expense = await showDialog<Expense>(
      context: context,
      builder: (context) => AddExpenseDialog(currency: budget.currency),
    );

    if (expense != null) {
      await ref.read(budgetProvider(widget.itineraryId).notifier).addExpense(
            expense,
          );
    }
  }

  void _showExpensesList(BuildContext context, Budget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpensesListScreen(budget: budget),
      ),
    );
  }
}
