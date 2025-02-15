import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/itinerary.dart';
import 'base_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

enum NotificationType {
  activityReminder,
  flightStatus,
  weatherAlert,
  budgetAlert,
  checkInReminder,
  tripStart,
  tripEnd,
  customAlert
}

class NotificationService implements BaseService {
  final FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  NotificationService([FlutterLocalNotificationsPlugin? notifications])
      : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    _isInitialized = true;
  }

  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) {
      // Web platform doesn't support local notifications yet
      return false;
    }

    if (Platform.isAndroid) {
      // Request Android notification permission by checking and requesting if needed
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final bool enabled =
            await androidImplementation.areNotificationsEnabled() ?? false;
        if (!enabled) {
          // On Android 13 and above, this will show the system permission dialog
          await _notifications.initialize(
            const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            ),
          );
        }
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }
      return false;
    } else if (Platform.isIOS) {
      // Request iOS notification permission
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Schedule activity reminders
  Future<void> scheduleActivityReminder(
    Activity activity, {
    Duration reminderBefore = const Duration(minutes: 30),
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      activity.startTime.subtract(reminderBefore),
      tz.local,
    );

    await _notifications.zonedSchedule(
      activity.hashCode,
      'Activity Reminder',
      'Your activity "${activity.name}" starts in ${reminderBefore.inMinutes} minutes',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_reminders',
          'Activity Reminders',
          channelDescription: 'Notifications for upcoming activities',
          importance: Importance.high,
          priority: Priority.high,
          color: activity.category.getColor(const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF1E88E5),
            onPrimary: Colors.white,
            secondary: Color(0xFF26A69A),
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            background: Colors.white,
            onBackground: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          )),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'activity:${activity.hashCode}',
    );
  }

  // Schedule trip start notification
  Future<void> scheduleTripStartReminder(
    Itinerary itinerary, {
    Duration reminderBefore = const Duration(days: 1),
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      itinerary.startDate.subtract(reminderBefore),
      tz.local,
    );

    await _notifications.zonedSchedule(
      itinerary.hashCode,
      'Trip Starting Soon',
      'Your trip to ${itinerary.destinations.first} starts tomorrow!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_reminders',
          'Trip Reminders',
          channelDescription: 'Notifications for trip start and end',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'trip:${itinerary.id}',
    );
  }

  // Show weather alert
  Future<void> showWeatherAlert({
    required String location,
    required String alert,
    required String description,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      'Weather Alert: $location',
      description,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_alerts',
          'Weather Alerts',
          channelDescription: 'Important weather updates for your trip',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'weather:$location',
    );
  }

  // Show budget alert
  Future<void> showBudgetAlert({
    required String title,
    required String message,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications about your travel budget',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'budget_alert',
    );
  }

  // Show check-in reminder
  Future<void> scheduleCheckInReminder({
    required DateTime checkInTime,
    required String flightNumber,
    Duration reminderBefore = const Duration(hours: 24),
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      checkInTime.subtract(reminderBefore),
      tz.local,
    );

    await _notifications.zonedSchedule(
      flightNumber.hashCode,
      'Check-in Reminder',
      'Online check-in is now available for your flight $flightNumber',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'checkin_reminders',
          'Check-in Reminders',
          channelDescription: 'Reminders for flight check-ins',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'checkin:$flightNumber',
    );
  }

  // Show custom notification
  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_notifications',
          'Custom Notifications',
          channelDescription: 'Custom travel notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  @override
  Future<void> dispose() async {
    await cancelAllNotifications();
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> reset() async {
    await cancelAllNotifications();
    _isInitialized = false;
    await initialize();
  }

  @override
  String get serviceName => 'NotificationService';
}
