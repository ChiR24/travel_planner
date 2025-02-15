import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notification_provider.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notificationSettings = ref.watch(notificationSettingsProvider);

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
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Activity Reminders',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'Enable Reminders',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Get notified about upcoming activities',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
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
                  ListTile(
                    title: Text(
                      'Reminder Time',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      'How early to remind you',
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    trailing: DropdownButton<int>(
                      value: notificationSettings.reminderMinutes,
                      items: [15, 30, 60, 120].map((minutes) {
                        final text = minutes < 60
                            ? '$minutes minutes'
                            : '${minutes ~/ 60} hour${minutes == 60 ? '' : 's'}';
                        return DropdownMenuItem(
                          value: minutes,
                          child: Text(
                            text,
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .setReminderMinutes(value);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Trip Updates',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'Trip Changes',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Get notified about changes to your trips',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
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
        ],
      ),
    );
  }
}
