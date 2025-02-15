import 'package:flutter/material.dart';

enum ActivityCategory {
  sightseeing('🏛️', 'Sightseeing'),
  dining('🍽️', 'Dining'),
  shopping('🛍️', 'Shopping'),
  entertainment('🎭', 'Entertainment'),
  relaxation('🌅', 'Relaxation'),
  adventure('🏃', 'Adventure'),
  culture('🎨', 'Culture'),
  nature('🌲', 'Nature'),
  transportation('🚗', 'Transportation'),
  business('💼', 'Business'),
  other('📌', 'Other');

  final String icon;
  final String label;

  const ActivityCategory(this.icon, this.label);

  @override
  String toString() => label;

  static ActivityCategory fromString(String value) {
    return ActivityCategory.values.firstWhere(
      (e) => e.label == value,
      orElse: () => ActivityCategory.other,
    );
  }

  static List<ActivityCategory> get recommended => [
        sightseeing,
        dining,
        entertainment,
        culture,
        nature,
      ];

  static List<ActivityCategory> get all => ActivityCategory.values;

  String get emoji => icon;

  Color getColor(ColorScheme colorScheme) {
    switch (this) {
      case ActivityCategory.sightseeing:
        return colorScheme.primary;
      case ActivityCategory.dining:
        return Colors.orange;
      case ActivityCategory.shopping:
        return Colors.pink;
      case ActivityCategory.entertainment:
        return Colors.purple;
      case ActivityCategory.relaxation:
        return Colors.teal;
      case ActivityCategory.adventure:
        return Colors.green;
      case ActivityCategory.culture:
        return Colors.indigo;
      case ActivityCategory.nature:
        return Colors.lightGreen;
      case ActivityCategory.transportation:
        return Colors.blue;
      case ActivityCategory.business:
        return Colors.blueGrey;
      case ActivityCategory.other:
        return Colors.grey;
    }
  }
}
