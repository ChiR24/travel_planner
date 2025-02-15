import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';
import 'package:go_router/go_router.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSettings = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'Appearance',
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
                    'Theme Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'System',
                    style: GoogleFonts.poppins(),
                  ),
                  value: ThemeMode.system,
                  groupValue: themeSettings.themeMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setThemeMode(value!);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Light',
                    style: GoogleFonts.poppins(),
                  ),
                  value: ThemeMode.light,
                  groupValue: themeSettings.themeMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setThemeMode(value!);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Dark',
                    style: GoogleFonts.poppins(),
                  ),
                  value: ThemeMode.dark,
                  groupValue: themeSettings.themeMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setThemeMode(value!);
                  },
                ),
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
                    'Text Size',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.text_fields, size: 20),
                      Expanded(
                        child: Slider(
                          value: themeSettings.textScaleFactor,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          label:
                              '${(themeSettings.textScaleFactor * 100).round()}%',
                          onChanged: (value) {
                            ref
                                .read(themeProvider.notifier)
                                .setTextScaleFactor(value);
                          },
                        ),
                      ),
                      const Icon(Icons.text_fields, size: 24),
                    ],
                  ),
                ),
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
                    'Contrast',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'High Contrast',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Increase contrast for better readability',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  value: themeSettings.highContrast,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setHighContrast(value);
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
