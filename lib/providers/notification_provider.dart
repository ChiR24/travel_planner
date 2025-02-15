import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'storage_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for notification settings
class NotificationSettings {
  final bool activityReminders;
  final int reminderMinutes;
  final bool tripUpdates;

  const NotificationSettings({
    this.activityReminders = false,
    this.reminderMinutes = 30,
    this.tripUpdates = false,
  });

  NotificationSettings copyWith({
    bool? activityReminders,
    int? reminderMinutes,
    bool? tripUpdates,
  }) {
    return NotificationSettings(
      activityReminders: activityReminders ?? this.activityReminders,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      tripUpdates: tripUpdates ?? this.tripUpdates,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  NotificationSettingsNotifier(this._prefs, this._notificationService)
      : super(NotificationSettings(
          activityReminders: _prefs.getBool('activityReminders') ?? false,
          reminderMinutes: _prefs.getInt('reminderMinutes') ?? 30,
          tripUpdates: _prefs.getBool('tripUpdates') ?? false,
        ));

  void setActivityReminders(bool enabled) async {
    if (enabled) {
      final permissionGranted =
          await _notificationService.requestNotificationPermission();
      if (!permissionGranted) return;
    }
    _prefs.setBool('activityReminders', enabled);
    state = state.copyWith(activityReminders: enabled);
  }

  void setReminderMinutes(int minutes) {
    _prefs.setInt('reminderMinutes', minutes);
    state = state.copyWith(reminderMinutes: minutes);
  }

  void setTripUpdates(bool enabled) async {
    if (enabled) {
      final permissionGranted =
          await _notificationService.requestNotificationPermission();
      if (!permissionGranted) return;
    }
    _prefs.setBool('tripUpdates', enabled);
    state = state.copyWith(tripUpdates: enabled);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(prefs, notificationService);
});

// Provider for pending notifications
final pendingNotificationsProvider = StreamProvider<List<PendingNotification>>(
  (ref) {
    final service = ref.watch(notificationServiceProvider);
    // TODO: Implement pending notifications stream
    return Stream.value([]);
  },
);

class PendingNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final NotificationType type;

  const PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.type,
  });
}
