import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trip_management_provider.dart';
import '../../models/itinerary.dart';
import 'package:intl/intl.dart';

class TripManagementScreen extends ConsumerWidget {
  const TripManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            'Trip Management',
            style: GoogleFonts.poppins(),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Statistics'),
              Tab(text: 'Active'),
              Tab(text: 'Archived'),
              Tab(text: 'Templates'),
            ],
            labelStyle: GoogleFonts.poppins(),
          ),
        ),
        body: TabBarView(
          children: [
            _buildStatisticsTab(context, ref),
            _buildActiveTripsTab(context, ref),
            _buildArchivedTripsTab(context, ref),
            _buildTemplatesTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(tripStatisticsProvider);

    return statistics.when(
      data: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            context,
            title: 'Trip Overview',
            stats: [
              StatItem(
                label: 'Total Trips',
                value: data['totalTrips'].toString(),
                icon: Icons.map,
              ),
              StatItem(
                label: 'Active Trips',
                value: data['activeTrips'].toString(),
                icon: Icons.directions_car,
              ),
              StatItem(
                label: 'Archived Trips',
                value: data['archivedTrips'].toString(),
                icon: Icons.archive,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            title: 'Destinations',
            stats: [
              StatItem(
                label: 'Total Destinations',
                value: data['totalDestinations'].toString(),
                icon: Icons.place,
              ),
              StatItem(
                label: 'Total Trip Days',
                value: data['totalTripDays'].toString(),
                icon: Icons.calendar_today,
              ),
              StatItem(
                label: 'Average Duration',
                value:
                    '${(data['averageTripDuration'] as Duration).inDays} days',
                icon: Icons.timelapse,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMostVisitedPlaces(
              context, data['mostVisitedDestinations'] as Map<String, int>),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading statistics: $error'),
      ),
    );
  }

  Widget _buildActiveTripsTab(BuildContext context, WidgetRef ref) {
    final activeTrips = ref.watch(activeTripsProvider);

    return activeTrips.when(
      data: (trips) => trips.isEmpty
          ? const Center(child: Text('No active trips'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) => _buildTripCard(
                context,
                ref,
                trips[index],
                isActive: true,
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading trips: $error'),
      ),
    );
  }

  Widget _buildArchivedTripsTab(BuildContext context, WidgetRef ref) {
    final archivedTrips = ref.watch(archivedTripsProvider);

    return archivedTrips.when(
      data: (trips) => trips.isEmpty
          ? const Center(child: Text('No archived trips'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) => _buildTripCard(
                context,
                ref,
                trips[index],
                isActive: false,
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading archived trips: $error'),
      ),
    );
  }

  Widget _buildTemplatesTab(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(tripTemplatesProvider);

    return templates.when(
      data: (templates) => templates.isEmpty
          ? const Center(child: Text('No trip templates'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) => _buildTemplateCard(
                context,
                ref,
                templates[index],
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading templates: $error'),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required List<StatItem> stats,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: stats.map((stat) {
                return Expanded(
                  child: Column(
                    children: [
                      Icon(
                        stat.icon,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat.value,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stat.label,
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostVisitedPlaces(
      BuildContext context, Map<String, int> places) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Visited Places',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...places.entries.take(5).map((entry) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${entry.value} ${entry.value == 1 ? 'visit' : 'visits'}',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    WidgetRef ref,
    Itinerary trip, {
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      child: ListTile(
        title: Text(
          'Trip to ${trip.destinations.join(', ')}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
          style: GoogleFonts.poppins(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'view':
                context.go('/itinerary/${trip.id}');
                break;
              case 'archive':
                if (isActive) {
                  await ref
                      .read(tripActionsProvider.notifier)
                      .archiveTrip(trip);
                } else {
                  await ref
                      .read(tripActionsProvider.notifier)
                      .unarchiveTrip(trip.id);
                }
                break;
              case 'template':
                await ref.read(tripActionsProvider.notifier).saveTemplate(trip);
                break;
              case 'delete':
                await ref
                    .read(tripActionsProvider.notifier)
                    .deleteTrip(trip.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(isActive ? Icons.archive : Icons.unarchive),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Archive' : 'Unarchive'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'template',
              child: Row(
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Save as Template'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref,
    Itinerary template,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: ListTile(
        title: Text(
          'Template: ${template.destinations.join(', ')}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${template.duration.inDays} days',
          style: GoogleFonts.poppins(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'use':
                // TODO: Implement use template
                break;
              case 'delete':
                await ref
                    .read(tripActionsProvider.notifier)
                    .deleteTemplate(template.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'use',
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Use Template'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final IconData icon;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
