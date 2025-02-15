import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/storage_provider.dart';
import '../../providers/offline_storage_provider.dart';

class DataStorageSettingsScreen extends ConsumerWidget {
  const DataStorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'Data & Storage',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Storage Usage',
            children: [
              ListTile(
                title: const Text('Cache Size'),
                subtitle: const Text('Clear app cache to free up space'),
                trailing: TextButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Clear Cache',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Are you sure you want to clear the app cache? This will remove all cached images and data.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      // Clear cache
                      await ref.read(storageServiceProvider).clearCache();
                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cache cleared successfully'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Clear'),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Database Size'),
                subtitle: const Text('View and manage database storage'),
                trailing: FutureBuilder<String>(
                  future: ref.read(storageServiceProvider).getDatabaseSize(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: GoogleFonts.poppins(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Offline Mode',
            children: [
              SwitchListTile(
                title: const Text('Enable Offline Mode'),
                subtitle: const Text(
                  'Access your trips and data without an internet connection',
                ),
                value: isOffline,
                onChanged: (value) {
                  // Toggle offline mode
                  ref.read(isOfflineProvider.notifier).state = value;
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Sync Status'),
                subtitle: Text(
                  isOffline ? 'Last synced: Never' : 'Synced',
                  style: TextStyle(
                    color: isOffline ? colorScheme.error : colorScheme.primary,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: isOffline
                      ? null
                      : () {
                          // Trigger sync
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Syncing data...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Data Management',
            children: [
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Export your trips and settings'),
                trailing: const Icon(Icons.download),
                onTap: () {
                  // TODO: Implement data export
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Import Data'),
                subtitle: const Text('Import trips and settings from a file'),
                trailing: const Icon(Icons.upload),
                onTap: () {
                  // TODO: Implement data import
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Delete All Data',
                  style: TextStyle(color: colorScheme.error),
                ),
                subtitle: const Text(
                  'Permanently delete all your data and settings',
                ),
                trailing: Icon(Icons.delete_forever, color: colorScheme.error),
                onTap: () async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Delete All Data',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to delete all your data? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    // Delete all data
                    await ref.read(storageServiceProvider).clearAll();
                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All data deleted successfully'),
                        ),
                      );
                      // Go back to home screen
                      context.go('/');
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
