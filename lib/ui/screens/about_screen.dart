import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'About',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.travel_explore,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Travel Planner',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                packageInfo.when(
                  data: (info) => Text(
                    'Version ${info.version} (${info.buildNumber})',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) =>
                      const Text('Version information unavailable'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: 'App Information',
            content: 'Travel Planner is your all-in-one travel companion app. '
                'Plan trips, manage itineraries, and keep track of your travel experiences '
                'with ease.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Features',
            content: '• Trip Planning\n'
                '• Itinerary Management\n'
                '• Activity Scheduling\n'
                '• Travel Metrics\n'
                '• Offline Support\n'
                '• Dark Mode',
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(
              'Licenses',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Travel Planner',
              applicationVersion: packageInfo.when(
                data: (info) => '${info.version} (${info.buildNumber})',
                loading: () => '',
                error: (_, __) => 'Unknown',
              ),
              applicationIcon: Icon(
                Icons.travel_explore,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© ${DateTime.now().year} Travel Planner',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
