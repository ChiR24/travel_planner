import 'package:travel_planner_2/models/destination.dart';

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

  Activity({
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
