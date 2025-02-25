import 'package:flutter/material.dart';
import 'activity_category.dart';

class Activity {
  final String? id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final ActivityCategory category;
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic> metadata;

  Activity({
    this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.category = ActivityCategory.other,
    this.tags = const [],
    this.latitude,
    this.longitude,
    this.metadata = const {},
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      category: ActivityCategory.fromString(json['category'] as String? ?? ''),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category.toString(),
      'tags': tags,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'metadata': metadata,
    };
  }

  Activity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    ActivityCategory? category,
    List<String>? tags,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

  @override
  String toString() => 'Activity(name: $name, duration: $duration)';
}
