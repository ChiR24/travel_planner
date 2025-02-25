import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';

/// Provider for the WeatherService
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

/// Provider for current weather data
final currentWeatherProvider =
    FutureProvider.family<WeatherData, String>((ref, location) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return weatherService.getCurrentWeather(location);
});

/// Provider for weather forecast
final forecastProvider =
    FutureProvider.family<List<WeatherData>, ForecastParams>(
        (ref, params) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return weatherService.getForecast(params.location, days: params.days);
});

/// Provider for multiple locations weather data
final multiLocationWeatherProvider =
    FutureProvider.family<Map<String, WeatherData>, List<String>>(
        (ref, locations) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return weatherService.getWeatherForMultipleLocations(locations);
});

/// Class to hold forecast parameters
class ForecastParams {
  final String location;
  final int days;

  ForecastParams({required this.location, this.days = 3});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForecastParams &&
        other.location == location &&
        other.days == days;
  }

  @override
  int get hashCode => location.hashCode ^ days.hashCode;
}
