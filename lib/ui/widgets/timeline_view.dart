import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/itinerary.dart';
import '../../providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show lerpDouble;

class TimelineView extends ConsumerWidget {
  final List<Activity> activities;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(Activity) onActivityTap;

  const TimelineView({
    super.key,
    required this.activities,
    required this.onReorder,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double elevation = lerpDouble(0, 8, animation.value)!;
            final double scale = lerpDouble(1, 1.02, animation.value)!;
            final double opacity = lerpDouble(1, 0.8, animation.value)!;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Material(
                  elevation: elevation,
                  color: Colors.transparent,
                  shadowColor: colorScheme.shadow.withOpacity(0.3),
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isFirst = index == 0;
        final isLast = index == activities.length - 1;

        return TimelineTile(
          key: ValueKey(activity.name),
          activity: activity,
          isFirst: isFirst,
          isLast: isLast,
          onTap: () => onActivityTap(activity),
          animationDuration: const Duration(milliseconds: 300),
          reduceAnimations: false,
        );
      },
    );
  }
}

class TimelineTile extends StatelessWidget {
  final Activity activity;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final Duration animationDuration;
  final bool reduceAnimations;

  const TimelineTile({
    super.key,
    required this.activity,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.animationDuration,
    required this.reduceAnimations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeFormat = DateFormat('h:mm a');

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and dot
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    if (!isFirst)
                      AnimatedContainer(
                        duration: animationDuration,
                        width: 2,
                        height: 32,
                        color: activity.category
                            .getColor(colorScheme)
                            .withOpacity(0.2),
                      ),
                    AnimatedContainer(
                      duration: animationDuration,
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activity.category.getColor(colorScheme),
                        border: Border.all(
                          color: activity.category
                              .getColor(colorScheme)
                              .withOpacity(0.2),
                          width: 3,
                        ),
                      ),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: animationDuration,
                        width: 2,
                        height: 32,
                        color: activity.category
                            .getColor(colorScheme)
                            .withOpacity(0.2),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Activity details
              Expanded(
                child: AnimatedContainer(
                  duration: animationDuration,
                  child: Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: activity.category
                            .getColor(colorScheme)
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                timeFormat.format(activity.startTime),
                                style: GoogleFonts.poppins(
                                  color:
                                      activity.category.getColor(colorScheme),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                timeFormat.format(activity.endTime),
                                style: GoogleFonts.poppins(
                                  color: activity.category
                                      .getColor(colorScheme)
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: activity.category
                                      .getColor(colorScheme)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      activity.category.icon,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      activity.category.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: activity.category
                                            .getColor(colorScheme),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  activity.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (activity.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              activity.description,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (activity.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: activity.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.drag_indicator,
                                size: 20,
                                color: colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Drag to reorder',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
