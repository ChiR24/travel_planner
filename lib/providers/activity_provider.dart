import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';

class DayActivitiesNotifier extends StateNotifier<List<Activity>> {
  DayActivitiesNotifier(List<Activity> activities) : super(activities);

  void reorderActivities(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final activity = state[oldIndex];
    final newState = List<Activity>.from(state)..removeAt(oldIndex);
    newState.insert(newIndex, activity);

    // Update activity times based on new order
    DateTime currentTime = newState[0].startTime;
    for (int i = 0; i < newState.length; i++) {
      final activity = newState[i];
      final duration = activity.endTime.difference(activity.startTime);
      newState[i] = Activity(
        name: activity.name,
        description: activity.description,
        startTime: currentTime,
        endTime: currentTime.add(duration),
      );
      currentTime = currentTime.add(duration);
    }

    state = newState;
  }

  void addActivity(Activity activity) {
    // Insert the activity in the correct position based on start time
    final newState = List<Activity>.from(state);
    int insertIndex = newState.length;
    for (int i = 0; i < newState.length; i++) {
      if (activity.startTime.isBefore(newState[i].startTime)) {
        insertIndex = i;
        break;
      }
    }
    newState.insert(insertIndex, activity);
    state = newState;
  }

  void updateActivity(int index, Activity updatedActivity) {
    final newState = List<Activity>.from(state);
    newState[index] = updatedActivity;

    // Sort activities by start time
    newState.sort((a, b) => a.startTime.compareTo(b.startTime));
    state = newState;
  }

  void removeActivity(int index) {
    final newState = List<Activity>.from(state)..removeAt(index);
    state = newState;
  }
}

final dayActivitiesProvider =
    StateNotifierProvider.family<DayActivitiesNotifier, List<Activity>, Day>(
  (ref, day) => DayActivitiesNotifier(day.activities),
);
