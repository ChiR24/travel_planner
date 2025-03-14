import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'storage_provider.dart';

class ThemeSettings {
  final ThemeMode themeMode;
  final double textScaleFactor;
  final bool highContrast;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.textScaleFactor = 1.0,
    this.highContrast = false,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    double? textScaleFactor,
    bool? highContrast,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  static ThemeSettings get defaults => const ThemeSettings();
}

class ThemeNotifier extends AsyncNotifier<ThemeSettings> {
  @override
  Future<ThemeSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeSettings(
      themeMode:
          ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index],
      textScaleFactor: prefs.getDouble('textScaleFactor') ?? 1.0,
      highContrast: prefs.getBool('highContrast') ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setTextScaleFactor(double factor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScaleFactor', factor);
    state = AsyncData(state.value!.copyWith(textScaleFactor: factor));
  }

  Future<void> setHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', enabled);
    state = AsyncData(state.value!.copyWith(highContrast: enabled));
  }
}

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeSettings>(() {
  return ThemeNotifier();
});

final themeSettingsProvider = Provider<ThemeSettings>((ref) {
  return ref.watch(themeProvider).when(
        data: (settings) => settings,
        loading: () => ThemeSettings.defaults,
        error: (_, __) => ThemeSettings.defaults,
      );
});

final effectiveThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeSettingsProvider);
  final baseTheme = settings.themeMode == ThemeMode.dark
      ? AppTheme.darkTheme
      : AppTheme.lightTheme;

  // Apply high contrast if enabled
  final colorScheme = settings.highContrast
      ? baseTheme.colorScheme.copyWith(
          // Increase contrast by adjusting colors for light/dark modes
          primary: baseTheme.brightness == Brightness.dark
              ? baseTheme.colorScheme.primary.lighten(0.2)
              : baseTheme.colorScheme.primary.darken(0.2),
          onPrimary: baseTheme.brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          secondary: baseTheme.brightness == Brightness.dark
              ? baseTheme.colorScheme.secondary.lighten(0.2)
              : baseTheme.colorScheme.secondary.darken(0.2),
          onSecondary: baseTheme.brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          surface: baseTheme.brightness == Brightness.dark
              ? const Color(0xFF121212)
              : Colors.white,
          onSurface: baseTheme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          background: baseTheme.brightness == Brightness.dark
              ? const Color(0xFF000000)
              : Colors.white,
          onBackground: baseTheme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          surfaceVariant: baseTheme.brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFFF5F5F5),
          onSurfaceVariant: baseTheme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          outline: baseTheme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.3)
              : Colors.black.withOpacity(0.3),
        )
      : baseTheme.colorScheme;

  final updatedTheme = baseTheme.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    cardColor: colorScheme.surface,
    dialogBackgroundColor: colorScheme.surface,
    textTheme: baseTheme.textTheme.apply(
      bodyColor: colorScheme.onBackground,
      displayColor: colorScheme.onBackground,
    ),
    primaryTextTheme: baseTheme.primaryTextTheme.apply(
      bodyColor: colorScheme.onBackground,
      displayColor: colorScheme.onBackground,
    ),
  );

  // Apply additional high contrast adjustments
  if (settings.highContrast) {
    return updatedTheme.copyWith(
      dividerColor: colorScheme.onBackground.withOpacity(0.2),
      disabledColor: colorScheme.onBackground.withOpacity(0.38),
      hintColor: colorScheme.onBackground.withOpacity(0.6),
      unselectedWidgetColor: colorScheme.onBackground.withOpacity(0.6),
      iconTheme: updatedTheme.iconTheme.copyWith(
        color: colorScheme.onBackground,
      ),
      primaryIconTheme: updatedTheme.primaryIconTheme.copyWith(
        color: colorScheme.onBackground,
      ),
      appBarTheme: updatedTheme.appBarTheme.copyWith(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: updatedTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
      ),
      inputDecorationTheme: updatedTheme.inputDecorationTheme.copyWith(
        fillColor: colorScheme.surface,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
      ),
    );
  }

  return updatedTheme;
});

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(themeSettingsProvider);
  return settings.themeMode;
});

// Extension to help with color manipulation
extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
