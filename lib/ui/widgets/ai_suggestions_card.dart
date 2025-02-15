import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/ai_suggestions_provider.dart';
import '../../models/activity_category.dart';

class AISuggestionsCard extends ConsumerWidget {
  final String location;
  final DateTime date;
  final List<ActivityCategory> preferredCategories;
  final Map<String, dynamic> preferences;

  const AISuggestionsCard({
    super.key,
    required this.location,
    required this.date,
    required this.preferredCategories,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(activitySuggestionsProvider((
      location: location,
      date: date,
      preferredCategories: preferredCategories,
      preferences: preferences,
    )));
    final customsAsync = ref.watch(localCustomsProvider(location));
    final safetyAsync = ref.watch(safetyInfoProvider(location));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Text(
                  'AI Suggestions',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          suggestionsAsync.when(
            data: (suggestions) => _buildSuggestions(context, suggestions),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
          if (customsAsync.hasValue || safetyAsync.hasValue) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoSection(
                      context,
                      'Local Customs',
                      customsAsync,
                      Icons.people_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoSection(
                      context,
                      'Safety Info',
                      safetyAsync,
                      Icons.security_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestions(
    BuildContext context,
    Map<String, dynamic> suggestions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (suggestions['error'] != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          suggestions['error'].toString(),
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    final activities = suggestions['activities'] as List<dynamic>;
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No suggestions available.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (suggestions['weatherAlert'] != null) ...[
          _buildAlert(
            context,
            'Weather Alert',
            suggestions['weatherAlert'] as String,
            Icons.wb_sunny_outlined,
            colorScheme.primary,
          ),
          const SizedBox(height: 8),
        ],
        if (suggestions['culturalAlert'] != null) ...[
          _buildAlert(
            context,
            'Cultural Note',
            suggestions['culturalAlert'] as String,
            Icons.info_outline,
            colorScheme.secondary,
          ),
          const SizedBox(height: 8),
        ],
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index] as Map<String, dynamic>;
            final category = ActivityCategory.fromString(
              activity['category'] as String,
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    category.getColor(colorScheme).withOpacity(0.1),
                child: Text(
                  category.icon,
                  style: TextStyle(
                    color: category.getColor(colorScheme),
                  ),
                ),
              ),
              title: Text(
                activity['name'] as String,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity['description'] as String),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text(
                          '${activity['suggestedDuration']} min',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        avatar: const Icon(Icons.schedule, size: 16),
                      ),
                      ...(activity['tags'] as List<dynamic>).map(
                        (tag) => Chip(
                          label: Text(
                            '#$tag',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
            );
          },
        ),
        if (suggestions['localEvents'] != null &&
            (suggestions['localEvents'] as List).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local Events',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...(suggestions['localEvents'] as List).map(
                  (event) => ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(event.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    AsyncValue<Map<String, dynamic>> asyncValue,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        if (asyncValue.hasValue) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => _InfoDetailsSheet(
              title: title,
              data: asyncValue.value!,
              icon: icon,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (asyncValue.isLoading)
              const SizedBox(
                height: 2,
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDetailsSheet extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final IconData icon;

  const _InfoDetailsSheet({
    required this.title,
    required this.data,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: data.entries.map((entry) {
                    return _buildSection(
                      context,
                      entry.key,
                      entry.value as Map<String, dynamic>,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Map<String, dynamic> section,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...section.entries.map((entry) {
              if (entry.value is List) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...((entry.value as List).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          bottom: 4,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(
                              child: Text(
                                item.toString(),
                                style: GoogleFonts.poppins(
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value.toString(),
                      style: GoogleFonts.poppins(
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
