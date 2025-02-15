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
    final themeSettings = ref.watch(themeSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No activities planned for this day',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add activities',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

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
          key: ValueKey(activity.hashCode),
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

class TimelineTile extends StatefulWidget {
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
  State<TimelineTile> createState() => _TimelineTileState();
}

class _TimelineTileState extends State<TimelineTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeFormat = DateFormat('h:mm a');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
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
                        if (!widget.isFirst)
                          AnimatedContainer(
                            duration: widget.animationDuration,
                            width: 2,
                            height: 32,
                            color: widget.activity.category
                                .getColor(colorScheme)
                                .withOpacity(0.2),
                          ),
                        TweenAnimationBuilder<double>(
                          duration: widget.animationDuration,
                          tween: Tween<double>(
                            begin: 0.0,
                            end: _isHovered ? 1.2 : 1.0,
                          ),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.activity.category
                                      .getColor(colorScheme),
                                  border: Border.all(
                                    color: widget.activity.category
                                        .getColor(colorScheme)
                                        .withOpacity(0.2),
                                    width: 3,
                                  ),
                                  boxShadow: _isHovered
                                      ? [
                                          BoxShadow(
                                            color: widget.activity.category
                                                .getColor(colorScheme)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                        if (!widget.isLast)
                          AnimatedContainer(
                            duration: widget.animationDuration,
                            width: 2,
                            height: 32,
                            color: widget.activity.category
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
                      duration: widget.animationDuration,
                      transform: Matrix4.identity()
                        ..translate(
                          _isHovered ? 8.0 : 0.0,
                          0.0,
                          0.0,
                        ),
                      child: Card(
                        elevation: _isHovered ? 4 : 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: widget.activity.category
                                .getColor(colorScheme)
                                .withOpacity(_isHovered ? 0.5 : 0.2),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _isHovered
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.activity.category
                                          .getColor(colorScheme)
                                          .withOpacity(0.1),
                                      widget.activity.category
                                          .getColor(colorScheme)
                                          .withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  )
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      timeFormat
                                          .format(widget.activity.startTime),
                                      style: GoogleFonts.poppins(
                                        color: widget.activity.category
                                            .getColor(colorScheme),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      timeFormat
                                          .format(widget.activity.endTime),
                                      style: GoogleFonts.poppins(
                                        color: widget.activity.category
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
                                        color: widget.activity.category
                                            .getColor(colorScheme)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.activity.category.icon,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.activity.category.label,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: widget.activity.category
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
                                        widget.activity.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.activity.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.activity.description,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (widget.activity.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: widget.activity.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                      color: colorScheme.onSurface
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Drag to reorder',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.5),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
