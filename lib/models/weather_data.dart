class WeatherData {
  final String location;
  final String country;
  final double latitude;
  final double longitude;
  final double tempC;
  final double tempF;
  final String condition;
  final String conditionIcon;
  final double windKph;
  final String windDirection;
  final double humidity;
  final double feelsLikeC;
  final double feelsLikeF;
  final double uv;
  final DateTime lastUpdated;
  final bool isDay;
  final Map<String, dynamic> rawData;

  WeatherData({
    required this.location,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.tempC,
    required this.tempF,
    required this.condition,
    required this.conditionIcon,
    required this.windKph,
    required this.windDirection,
    required this.humidity,
    required this.feelsLikeC,
    required this.feelsLikeF,
    required this.uv,
    required this.lastUpdated,
    required this.isDay,
    required this.rawData,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'];
    final currentData = json['current'];

    return WeatherData(
      location: locationData['name'] ?? 'Unknown',
      country: locationData['country'] ?? 'Unknown',
      latitude: (locationData['lat'] ?? 0).toDouble(),
      longitude: (locationData['lon'] ?? 0).toDouble(),
      tempC: (currentData['temp_c'] ?? 0).toDouble(),
      tempF: (currentData['temp_f'] ?? 0).toDouble(),
      condition: currentData['condition']?['text'] ?? 'Unknown',
      conditionIcon: currentData['condition']?['icon'] != null
          ? 'https:${currentData['condition']['icon']}'
              .replaceAll('http:', 'https:')
          : '',
      windKph: (currentData['wind_kph'] ?? 0).toDouble(),
      windDirection: currentData['wind_dir'] ?? 'N/A',
      humidity: (currentData['humidity'] ?? 0).toDouble(),
      feelsLikeC: (currentData['feelslike_c'] ?? 0).toDouble(),
      feelsLikeF: (currentData['feelslike_f'] ?? 0).toDouble(),
      uv: (currentData['uv'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(currentData['last_updated_epoch'] is int
          ? DateTime.fromMillisecondsSinceEpoch(
                  currentData['last_updated_epoch'] * 1000)
              .toIso8601String()
          : (currentData['last_updated'] ?? DateTime.now().toIso8601String())),
      isDay: currentData['is_day'] == 1,
      rawData: json,
    );
  }

  // For forecast data which has a different structure
  factory WeatherData.fromForecastDay(
      Map<String, dynamic> json, Map<String, dynamic> locationData) {
    final dayData = json['day'];

    // Debug print to see what's in the dayData
    print('Forecast day data: $dayData');

    return WeatherData(
      location: locationData['name'] ?? 'Unknown',
      country: locationData['country'] ?? 'Unknown',
      latitude: (locationData['lat'] ?? 0).toDouble(),
      longitude: (locationData['lon'] ?? 0).toDouble(),
      tempC: (dayData['avgtemp_c'] ?? 0).toDouble(),
      tempF: (dayData['avgtemp_f'] ?? 0).toDouble(),
      condition: dayData['condition']?['text'] ?? 'Unknown',
      conditionIcon: dayData['condition']?['icon'] != null
          ? 'https:${dayData['condition']['icon']}'
              .replaceAll('http:', 'https:')
          : '',
      windKph: (dayData['maxwind_kph'] ?? 0).toDouble(),
      windDirection: 'N/A', // Not available in forecast day
      humidity: (dayData['avghumidity'] ?? 0).toDouble(),
      feelsLikeC: (dayData['avgtemp_c'] ?? 0)
          .toDouble(), // Not available in forecast, using avgtemp
      feelsLikeF: (dayData['avgtemp_f'] ?? 0)
          .toDouble(), // Not available in forecast, using avgtemp
      uv: (dayData['uv'] ?? 0).toDouble(),
      lastUpdated:
          DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isDay: true, // Default to day for forecast
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'temp_c': tempC,
      'temp_f': tempF,
      'condition': condition,
      'condition_icon': conditionIcon,
      'wind_kph': windKph,
      'wind_direction': windDirection,
      'humidity': humidity,
      'feels_like_c': feelsLikeC,
      'feels_like_f': feelsLikeF,
      'uv': uv,
      'last_updated': lastUpdated.toIso8601String(),
      'is_day': isDay,
    };
  }

  @override
  String toString() {
    return 'WeatherData(location: $location, tempC: $tempC°C, condition: $condition)';
  }
}
