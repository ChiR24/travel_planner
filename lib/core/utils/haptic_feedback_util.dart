import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A utility class for providing haptic feedback throughout the app.
class HapticFeedbackUtil {
  /// Provides light impact haptic feedback.
  /// Use for subtle interactions like selecting an item.
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Provides medium impact haptic feedback.
  /// Use for moderate interactions like confirming an action.
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Provides heavy impact haptic feedback.
  /// Use for significant interactions like completing a major action.
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Provides selection click haptic feedback.
  /// Use for selection events like tapping on a button.
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Provides vibration haptic feedback.
  /// Use for alerts or errors.
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Provides a custom pattern of haptic feedback.
  /// Use for custom interactions.
  static Future<void> customPattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }
}

/// Provider for the haptic feedback utility
final hapticFeedbackProvider = Provider<HapticFeedbackUtil>((ref) {
  return HapticFeedbackUtil();
});
