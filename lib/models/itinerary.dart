import 'package:travel_planner_2/models/destination.dart';
import 'activity_category.dart';

class ItineraryStop {
  final Destination destination;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final List<String> activities;
  final Map<String, dynamic> metadata;

  const ItineraryStop({
    required this.destination,
    required this.arrivalTime,
    required this.departureTime,
    this.activities = const [],
    this.metadata = const {},
  });

  factory ItineraryStop.fromJson(Map<String, dynamic> json) {
    return ItineraryStop(
      destination:
          Destination.fromJson(json['destination'] as Map<String, dynamic>),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      departureTime: DateTime.parse(json['departureTime'] as String),
      activities: (json['activities'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination.toJson(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'departureTime': departureTime.toIso8601String(),
      'activities': activities,
      'metadata': metadata,
    };
  }
}

class Itinerary {
  final String id;
  final String origin;
  final List<String> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> preferences;
  final List<Day> days;

  Itinerary({
    required this.id,
    required this.origin,
    required this.destinations,
    required this.startDate,
    required this.endDate,
    required this.preferences,
    required this.days,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destinations: (json['destinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      preferences: json['preferences'] as Map<String, dynamic>,
      days: (json['days'] as List<dynamic>)
          .map((e) => Day.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destinations': destinations,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'preferences': preferences,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  Duration get duration => endDate.difference(startDate);

  int get numberOfStops => destinations.length;

  List<String> get destinationNames => destinations;

  @override
  String toString() =>
      'Itinerary(id: $id, destinations: ${destinations.length} stops)';
}

class Day {
  final String location;
  final List<Activity> activities;

  Day({
    required this.location,
    required this.activities,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      location: json['location'] as String,
      activities: (json['activities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }
}

class Activity {
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final ActivityCategory category;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  Activity({
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.category = ActivityCategory.other,
    this.tags = const [],
    this.metadata = const {},
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      category: ActivityCategory.fromString(json['category'] as String? ?? ''),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category.toString(),
      'tags': tags,
      'metadata': metadata,
    };
  }

  Activity copyWith({
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    ActivityCategory? category,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Activity(
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  Duration get duration => endTime.difference(startTime);

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  Activity addTag(String tag) {
    if (!hasTag(tag)) {
      return copyWith(tags: [...tags, tag.toLowerCase()]);
    }
    return this;
  }

  Activity removeTag(String tag) {
    return copyWith(
      tags: tags.where((t) => t != tag.toLowerCase()).toList(),
    );
  }

  Activity updateMetadata(String key, dynamic value) {
    return copyWith(
      metadata: {...metadata, key: value},
    );
  }
}
