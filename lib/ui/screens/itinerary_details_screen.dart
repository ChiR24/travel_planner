import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/itinerary.dart';
import '../../providers/itinerary_provider.dart';
import '../../providers/activity_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/add_expense_dialog.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget.dart' hide Expense;
import '../../models/expense.dart';
import '../widgets/timeline_view.dart';
import '../widgets/activity_details_sheet.dart';
import '../widgets/budget_overview_card.dart';
import 'package:go_router/go_router.dart';
import '../widgets/edit_activity_dialog.dart';

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

class ItineraryDetailsScreen extends ConsumerWidget {
  final String itineraryId;

  const ItineraryDetailsScreen({
    super.key,
    required this.itineraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerary = ref.watch(itineraryByIdProvider(itineraryId));

    if (itinerary == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/my-itineraries'),
          ),
        ),
        body: const Center(
          child: Text('Itinerary not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/my-itineraries'),
        ),
        title: Text(
          'Trip to ${itinerary.destinations.join(', ')}',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // TODO: Show full map view
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: itinerary.days.length,
        itemBuilder: (context, index) {
          final day = itinerary.days[index];
          return _buildDaySection(context, ref, day, index + 1);
        },
      ),
    );
  }

  Widget _buildDaySection(
      BuildContext context, WidgetRef ref, Day day, int dayNumber) {
    final activities = ref.watch(dayActivitiesProvider(day));
    final activitiesNotifier = ref.read(dayActivitiesProvider(day).notifier);

    // Calculate day start and end times
    final dayStartTime = activities.isEmpty
        ? DateTime(
            day.activities.first.startTime.year,
            day.activities.first.startTime.month,
            day.activities.first.startTime.day,
            9,
            0)
        : activities.first.startTime;
    final dayEndTime = activities.isEmpty
        ? dayStartTime.add(const Duration(hours: 12))
        : activities.last.endTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $dayNumber - ${day.location}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
                onPressed: () async {
                  final activity = await showDialog<Activity>(
                    context: context,
                    builder: (context) => EditActivityDialog(
                      dayStartTime: dayStartTime,
                      dayEndTime: dayEndTime,
                    ),
                  );

                  if (activity != null && context.mounted) {
                    activitiesNotifier.addActivity(activity);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TimelineView(
          activities: activities,
          onReorder: (oldIndex, newIndex) {
            activitiesNotifier.reorderActivities(oldIndex, newIndex);
          },
          onActivityTap: (activity) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ActivityDetailsSheet(
                activity: activity,
                onEdit: () async {
                  Navigator.pop(context); // Close the details sheet
                  final index = activities.indexOf(activity);
                  final updatedActivity = await showDialog<Activity>(
                    context: context,
                    builder: (context) => EditActivityDialog(
                      activity: activity,
                      dayStartTime: dayStartTime,
                      dayEndTime: dayEndTime,
                    ),
                  );

                  if (updatedActivity != null && context.mounted) {
                    activitiesNotifier.updateActivity(index, updatedActivity);
                  }
                },
                onDelete: () async {
                  Navigator.pop(context); // Close the details sheet
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Delete Activity',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        'Are you sure you want to delete this activity? This action cannot be undone.',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    final index = activities.indexOf(activity);
                    activitiesNotifier.removeActivity(index);
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
