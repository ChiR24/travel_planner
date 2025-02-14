import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences.dart';

class AccessibilityService {
  static const String _fontScaleKey = 'fontScale';
  static const String _highContrastKey = 'highContrast';
  static const String _reduceMotionKey = 'reduceMotion';

  final SharedPreferences _prefs;

  AccessibilityService(this._prefs);

  // Font scaling
  double get fontScale => _prefs.getDouble(_fontScaleKey) ?? 1.0;
  Future<void> setFontScale(double scale) async {
    await _prefs.setDouble(_fontScaleKey, scale);
  }

  // High contrast mode
  bool get isHighContrastEnabled => _prefs.getBool(_highContrastKey) ?? false;
  Future<void> setHighContrast(bool enabled) async {
    await _prefs.setBool(_highContrastKey, enabled);
  }

  // Reduce motion
  bool get reduceMotion => _prefs.getBool(_reduceMotionKey) ?? false;
  Future<void> setReduceMotion(bool enabled) async {
    await _prefs.setBool(_reduceMotionKey, enabled);
  }

  // Semantic labels for common actions
  static const Map<String, String> semanticLabels = {
    'plan_trip': 'Create a new trip itinerary',
    'my_trips': 'View your saved trips',
    'add_destination': 'Add a new destination to your trip',
    'generate_itinerary': 'Generate travel itinerary based on your preferences',
    'view_map': 'View route map and directions',
    'share_itinerary': 'Share your travel itinerary with others',
  };

  // Helper method to get semantic properties for widgets
  SemanticsProperties getSemanticsProperties(String key) {
    return SemanticsProperties(
      label: semanticLabels[key] ?? '',
      textDirection: TextDirection.ltr,
    );
  }

  // Get high contrast colors
  ColorScheme getHighContrastColors(bool isDark) {
    if (!isHighContrastEnabled) return _defaultColorScheme(isDark);

    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: isDark ? Colors.yellow : Colors.blue[900]!,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: isDark ? Colors.yellow[700]! : Colors.blue[700]!,
      onSecondary: isDark ? Colors.black : Colors.white,
      error: Colors.red[900]!,
      onError: Colors.white,
      surface: isDark ? Colors.grey[900]! : Colors.white,
      onSurface: isDark ? Colors.white : Colors.black,
    );
  }

  ColorScheme _defaultColorScheme(bool isDark) {
    return isDark ? const ColorScheme.dark() : const ColorScheme.light();
  }

  // Get text theme with appropriate scaling
  TextTheme getTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: (base.displayLarge?.fontSize ?? 96) * fontScale,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: (base.displayMedium?.fontSize ?? 60) * fontScale,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: (base.displaySmall?.fontSize ?? 48) * fontScale,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: (base.headlineMedium?.fontSize ?? 34) * fontScale,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: (base.headlineSmall?.fontSize ?? 24) * fontScale,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: (base.titleLarge?.fontSize ?? 20) * fontScale,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: (base.bodyLarge?.fontSize ?? 16) * fontScale,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: (base.bodyMedium?.fontSize ?? 14) * fontScale,
      ),
    );
  }

  // Animation duration based on reduce motion preference
  Duration getAnimationDuration(Duration standard) {
    return reduceMotion ? const Duration(milliseconds: 0) : standard;
  }
}
