import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/interactive_card.dart';
import '../widgets/shimmer_loading.dart';

final _themeSettingsLoadingProvider = StateProvider<bool>((ref) => true);

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final isLoading = ref.watch(_themeSettingsLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Simulate settings loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        ref.read(_themeSettingsLoadingProvider.notifier).state = false;
      }
    });

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
          ShimmerLoading(
            isLoading: isLoading,
            child: InteractiveCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.dark_mode, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Theme Mode',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildThemeModeOption(
                      context,
                      ref,
                      title: 'System',
                      subtitle: 'Follow system theme',
                      icon: Icons.brightness_auto,
                      value: ThemeMode.system,
                      groupValue: settings.themeMode,
                    ),
                    _buildThemeModeOption(
                      context,
                      ref,
                      title: 'Light',
                      subtitle: 'Light theme',
                      icon: Icons.light_mode,
                      value: ThemeMode.light,
                      groupValue: settings.themeMode,
                    ),
                    _buildThemeModeOption(
                      context,
                      ref,
                      title: 'Dark',
                      subtitle: 'Dark theme',
                      icon: Icons.dark_mode,
                      value: ThemeMode.dark,
                      groupValue: settings.themeMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShimmerLoading(
            isLoading: isLoading,
            child: InteractiveCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.text_fields,
                              color: colorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Text Size',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Scale: ${(settings.textScaleFactor * 100).round()}%',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _getTextSizeLabel(settings.textScaleFactor),
                              style: GoogleFonts.poppins(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.textScaleFactor,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          label: '${(settings.textScaleFactor * 100).round()}%',
                          onChanged: (value) async {
                            await ref
                                .read(themeProvider.notifier)
                                .setTextScaleFactor(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preview Text',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .fontSize! *
                                        settings.textScaleFactor,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShimmerLoading(
            isLoading: isLoading,
            child: InteractiveCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.contrast, color: colorScheme.tertiary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'High Contrast',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(
                        'Enable High Contrast',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Increases contrast for better visibility',
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      value: settings.highContrast,
                      onChanged: (value) async {
                        await ref
                            .read(themeProvider.notifier)
                            .setHighContrast(value);
                      },
                    ),
                  ],
                ),
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

  Widget _buildThemeModeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = value == groupValue;

    return InteractiveCard(
      onTap: () async {
        await ref.read(themeProvider.notifier).setThemeMode(value);
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
        child: RadioListTile<ThemeMode>(
          title: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: value,
          groupValue: groupValue,
          onChanged: (value) async {
            if (value != null) {
              await ref.read(themeProvider.notifier).setThemeMode(value);
            }
          },
        ),
      ),
    );
  }

  String _getTextSizeLabel(double scale) {
    if (scale <= 0.8) return 'Small';
    if (scale <= 1.0) return 'Normal';
    if (scale <= 1.2) return 'Large';
    return 'Extra Large';
  }
}
