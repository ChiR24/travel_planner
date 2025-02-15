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
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<bool> requestNotificationPermission() async {
    // TODO: Implement when notifications are re-added
    return false;
  }

  // Schedule activity reminders
  Future<void> scheduleActivityReminder(
    dynamic activity, {
    Duration reminderBefore = const Duration(minutes: 30),
  }) async {
    // TODO: Implement when notifications are re-added
  }

  // Schedule trip start notification
  Future<void> scheduleTripStartReminder(
    dynamic itinerary, {
    Duration reminderBefore = const Duration(days: 1),
  }) async {
    // TODO: Implement when notifications are re-added
  }

  // Show weather alert
  Future<void> showWeatherAlert({
    required String location,
    required String alert,
    required String description,
  }) async {
    // TODO: Implement when notifications are re-added
  }

  // Show budget alert
  Future<void> showBudgetAlert({
    required String title,
    required String message,
  }) async {
    // TODO: Implement when notifications are re-added
  }

  // Show check-in reminder
  Future<void> scheduleCheckInReminder({
    required DateTime checkInTime,
    required String flightNumber,
    Duration reminderBefore = const Duration(hours: 24),
  }) async {
    // TODO: Implement when notifications are re-added
  }

  // Show custom notification
  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // TODO: Implement when notifications are re-added
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    // TODO: Implement when notifications are re-added
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // TODO: Implement when notifications are re-added
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
