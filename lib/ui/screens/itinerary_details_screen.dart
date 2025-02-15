import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/itinerary.dart';
import '../../providers/itinerary_provider.dart';
import '../widgets/timeline_view.dart';
import '../widgets/activity_details_sheet.dart';
import '../widgets/interactive_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/edit_activity_dialog.dart';

final _detailsLoadingProvider = StateProvider<bool>((ref) => true);

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

class _ItineraryDetailsScreenState extends ConsumerState<ItineraryDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(_detailsLoadingProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addActivity(BuildContext context, Day day) async {
    final dayStartTime = day.activities.isEmpty
        ? DateTime(
            day.activities.first.startTime.year,
            day.activities.first.startTime.month,
            day.activities.first.startTime.day,
            9,
            0)
        : day.activities.first.startTime;
    final dayEndTime = day.activities.isEmpty
        ? dayStartTime.add(const Duration(hours: 12))
        : day.activities.last.endTime;

    final activity = await showDialog<Activity>(
      context: context,
      builder: (context) => EditActivityDialog(
        dayStartTime: dayStartTime,
        dayEndTime: dayEndTime,
      ),
    );

    if (activity != null && mounted) {
      final updatedDays = List<Day>.from(
          ref.read(itineraryByIdProvider(widget.itineraryId))!.days);
      final activities =
          List<Activity>.from(updatedDays[_selectedDayIndex].activities)
            ..add(activity)
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

      updatedDays[_selectedDayIndex] = Day(
        location: updatedDays[_selectedDayIndex].location,
        activities: activities,
      );

      await ref.read(itinerariesProvider.notifier).updateItinerary(
            ref.read(itineraryByIdProvider(widget.itineraryId))!.copyWith(
                  days: updatedDays,
                ),
          );
    }
  }

  Future<void> _editActivity(
      BuildContext context, Day day, Activity activity) async {
    final dayStartTime = day.activities.first.startTime;
    final dayEndTime = day.activities.last.endTime;

    final updatedActivity = await showDialog<Activity>(
      context: context,
      builder: (context) => EditActivityDialog(
        activity: activity,
        dayStartTime: dayStartTime,
        dayEndTime: dayEndTime,
      ),
    );

    if (updatedActivity != null && mounted) {
      final updatedDays = List<Day>.from(
          ref.read(itineraryByIdProvider(widget.itineraryId))!.days);
      final activities =
          List<Activity>.from(updatedDays[_selectedDayIndex].activities);
      final index =
          activities.indexWhere((a) => a.hashCode == activity.hashCode);

      if (index != -1) {
        activities[index] = updatedActivity;
        activities.sort((a, b) => a.startTime.compareTo(b.startTime));

        updatedDays[_selectedDayIndex] = Day(
          location: updatedDays[_selectedDayIndex].location,
          activities: activities,
        );

        await ref.read(itinerariesProvider.notifier).updateItinerary(
              ref.read(itineraryByIdProvider(widget.itineraryId))!.copyWith(
                    days: updatedDays,
                  ),
            );
      }
    }
  }

  Future<void> _deleteActivity(BuildContext context, Activity activity) async {
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
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final updatedDays = List<Day>.from(
          ref.read(itineraryByIdProvider(widget.itineraryId))!.days);
      final activities =
          List<Activity>.from(updatedDays[_selectedDayIndex].activities);
      activities.removeWhere((a) => a.hashCode == activity.hashCode);

      updatedDays[_selectedDayIndex] = Day(
        location: updatedDays[_selectedDayIndex].location,
        activities: activities,
      );

      await ref.read(itinerariesProvider.notifier).updateItinerary(
            ref.read(itineraryByIdProvider(widget.itineraryId))!.copyWith(
                  days: updatedDays,
                ),
          );
    }
  }

  Future<void> _reorderActivities(int oldIndex, int newIndex) async {
    final updatedDays = List<Day>.from(
        ref.read(itineraryByIdProvider(widget.itineraryId))!.days);
    final activities =
        List<Activity>.from(updatedDays[_selectedDayIndex].activities);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final activity = activities.removeAt(oldIndex);
    activities.insert(newIndex, activity);

    updatedDays[_selectedDayIndex] = Day(
      location: updatedDays[_selectedDayIndex].location,
      activities: activities,
    );

    await ref.read(itinerariesProvider.notifier).updateItinerary(
          ref.read(itineraryByIdProvider(widget.itineraryId))!.copyWith(
                days: updatedDays,
              ),
        );
  }

  Future<void> _shareItinerary(
      BuildContext context, Itinerary itinerary) async {
    final dateFormat = DateFormat('MMM d, y');
    final shareText = '''
🌍 Travel Itinerary: ${itinerary.destinations.join(' → ')}

📅 ${dateFormat.format(itinerary.startDate)} - ${dateFormat.format(itinerary.endDate)}
📍 Starting from: ${itinerary.origin}

Daily Activities:
${itinerary.days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      return '''
Day ${index + 1} - ${day.location}
${day.activities.map((activity) => '''
• ${DateFormat('h:mm a').format(activity.startTime)} - ${DateFormat('h:mm a').format(activity.endTime)}
  ${activity.name}
  ${activity.description.isNotEmpty ? '  ${activity.description}\\n' : ''}''').join()}
''';
    }).join('\\n')}

Created with Travel Planner
''';

    await Share.share(
      shareText,
      subject: 'Travel Itinerary: ${itinerary.destinations.join(' → ')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = ref.watch(_detailsLoadingProvider);
    final itinerary = ref.watch(itineraryByIdProvider(widget.itineraryId));

    if (itinerary == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Itinerary not found',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, y');
    final days = itinerary.days;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.surface.withOpacity(0.8),
                    ],
                  ).createShader(bounds),
                  blendMode: BlendMode.srcOver,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1200',
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  itinerary.destinations.join(' → '),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement full itinerary edit
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Full itinerary editing coming soon!'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareItinerary(context, itinerary),
                ),
              ],
            ),
            // Trip Overview
            SliverToBoxAdapter(
              child: ShimmerLoading(
                isLoading: isLoading,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InteractiveCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.map,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trip Overview',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      '${dateFormat.format(itinerary.startDate)} - ${dateFormat.format(itinerary.endDate)}',
                                      style: GoogleFonts.poppins(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${days.length} Days',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(days.length, (index) {
                                final day = days[index];
                                final isSelected = index == _selectedDayIndex;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InteractiveCard(
                                    onTap: () {
                                      setState(() {
                                        _selectedDayIndex = index;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.outline
                                                  .withOpacity(0.5),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Day ${index + 1}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? colorScheme.onPrimary
                                                  : colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            day.location,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: isSelected
                                                  ? colorScheme.onPrimary
                                                      .withOpacity(0.8)
                                                  : colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Activities Timeline
            SliverToBoxAdapter(
              child: ShimmerLoading(
                isLoading: isLoading,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InteractiveCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: colorScheme.secondary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Day ${_selectedDayIndex + 1} Activities',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    Text(
                                      days[_selectedDayIndex].location,
                                      style: GoogleFonts.poppins(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _addActivity(
                                    context, days[_selectedDayIndex]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TimelineView(
                            activities: days[_selectedDayIndex].activities,
                            onReorder: _reorderActivities,
                            onActivityTap: (activity) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ActivityDetailsSheet(
                                  activity: activity,
                                  onEdit: () {
                                    Navigator.pop(context);
                                    _editActivity(context,
                                        days[_selectedDayIndex], activity);
                                  },
                                  onDelete: () {
                                    Navigator.pop(context);
                                    _deleteActivity(context, activity);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement export/share itinerary
        },
        icon: const Icon(Icons.share),
        label: Text(
          'Share Itinerary',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }
}
