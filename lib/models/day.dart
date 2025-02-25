import 'activity.dart';

class Day {
  final String? id;
  final DateTime date;
  final List<Activity>? activities;
  final String notes;

  Day({
    this.id,
    required this.date,
    this.activities,
    this.notes = '',
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      activities: json['activities'] != null
          ? (json['activities'] as List)
              .map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      if (activities != null)
        'activities': activities!.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  Day copyWith({
    String? id,
    DateTime? date,
    List<Activity>? activities,
    String? notes,
  }) {
    return Day(
      id: id ?? this.id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
    );
  }

  int get activityCount => activities?.length ?? 0;

  Duration get totalDuration {
    if (activities == null || activities!.isEmpty) {
      return Duration.zero;
    }

    return activities!.fold(
      Duration.zero,
      (total, activity) => total + activity.duration,
    );
  }

  @override
  String toString() => 'Day(date: $date, activities: $activityCount)';
}
