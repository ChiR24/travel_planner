import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSettings = ref.watch(themeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Appearance',
            icon: Icons.palette_outlined,
            onTap: () => context.go('/settings/theme'),
            subtitle: 'Theme, colors, and text size',
            trailing: Text(
              themeSettings.themeMode == ThemeMode.system
                  ? 'System'
                  : themeSettings.themeMode == ThemeMode.light
                      ? 'Light'
                      : 'Dark',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            onTap: () => context.go('/settings/notifications'),
            subtitle: 'Activity reminders and alerts',
            trailing: Text(
              notificationSettings.activityReminders ? 'On' : 'Off',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'About',
            icon: Icons.info_outline,
            onTap: () => context.go('/settings/about'),
            subtitle: 'App version, licenses, and credits',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
        onTap: onTap,
      ),
    );
  }
}
