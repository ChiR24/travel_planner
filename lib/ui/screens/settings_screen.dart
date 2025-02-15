import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../widgets/interactive_card.dart';
import '../widgets/shimmer_loading.dart';

final _settingsLoadingProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSettings = ref.watch(themeSettingsProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final isLoading = ref.watch(_settingsLoadingProvider);

    // Simulate settings loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        ref.read(_settingsLoadingProvider.notifier).state = false;
      }
    });

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
          ShimmerLoading(
            isLoading: isLoading,
            child: _buildSection(
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
              badgeColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ShimmerLoading(
            isLoading: isLoading,
            child: _buildSection(
              context,
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              onTap: () => context.go('/settings/notifications'),
              subtitle: 'Activity reminders and alerts',
              trailing: Text(
                notificationSettings.activityReminders ? 'On' : 'Off',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              badgeColor: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          ShimmerLoading(
            isLoading: isLoading,
            child: _buildSection(
              context,
              title: 'About',
              icon: Icons.info_outline,
              onTap: () => context.go('/settings/about'),
              subtitle: 'App version, licenses, and credits',
              badgeColor: colorScheme.tertiary,
            ),
          ),
          if (!isLoading) ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Travel Planner v1.0.0',
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String subtitle,
    Widget? trailing,
    required Color badgeColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveCard(
      onTap: onTap,
      elevation: 1,
      pressedElevation: 4,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  badgeColor.withOpacity(0.1),
                  badgeColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.6],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: badgeColor),
              ),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              trailing: trailing != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        trailing,
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
