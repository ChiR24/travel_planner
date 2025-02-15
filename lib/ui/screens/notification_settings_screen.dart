import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/interactive_card.dart';
import '../widgets/shimmer_loading.dart';

final _notificationSettingsLoadingProvider = StateProvider<bool>((ref) => true);

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final isLoading = ref.watch(_notificationSettingsLoadingProvider);

    // Simulate settings loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        ref.read(_notificationSettingsLoadingProvider.notifier).state = false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShimmerLoading(
            isLoading: isLoading,
            child: InteractiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.notifications_active,
                              color: colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Activity Reminders',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Enable Reminders',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Get notified about upcoming activities',
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    value: notificationSettings.activityReminders,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setActivityReminders(value);
                    },
                  ),
                  if (notificationSettings.activityReminders) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder Time',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How early to remind you',
                            style: GoogleFonts.poppins(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTimeOption(
                            context,
                            ref,
                            minutes: 15,
                            currentMinutes:
                                notificationSettings.reminderMinutes,
                          ),
                          _buildTimeOption(
                            context,
                            ref,
                            minutes: 30,
                            currentMinutes:
                                notificationSettings.reminderMinutes,
                          ),
                          _buildTimeOption(
                            context,
                            ref,
                            minutes: 60,
                            currentMinutes:
                                notificationSettings.reminderMinutes,
                          ),
                          _buildTimeOption(
                            context,
                            ref,
                            minutes: 120,
                            currentMinutes:
                                notificationSettings.reminderMinutes,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShimmerLoading(
            isLoading: isLoading,
            child: InteractiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.update, color: colorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Trip Updates',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Trip Changes',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Get notified about changes to your trips',
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    value: notificationSettings.tripUpdates,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setTripUpdates(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (!isLoading) ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Changes are saved automatically',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeOption(
    BuildContext context,
    WidgetRef ref, {
    required int minutes,
    required int currentMinutes,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = minutes == currentMinutes;
    final text = minutes < 60
        ? '$minutes minutes'
        : '${minutes ~/ 60} hour${minutes == 60 ? '' : 's'}';

    return InteractiveCard(
      onTap: () {
        ref
            .read(notificationSettingsProvider.notifier)
            .setReminderMinutes(minutes);
      },
      elevation: 0,
      pressedElevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: RadioListTile<int>(
          title: Row(
            children: [
              Icon(
                Icons.timer,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          value: minutes,
          groupValue: currentMinutes,
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .setReminderMinutes(value);
            }
          },
        ),
      ),
    );
  }
}
