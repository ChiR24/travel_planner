import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/weather_data.dart';

class WeatherService {
  final String _apiKey;
  final String _baseUrl = 'https://api.weatherapi.com/v1';

  WeatherService({String? apiKey})
      : _apiKey = apiKey ?? ApiConfig.weatherApiKey;

  /// Fetches current weather data for a location
  Future<WeatherData> getCurrentWeather(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$location&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  /// Fetches weather forecast for a location
  Future<List<WeatherData>> getForecast(String location, {int days = 3}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/forecast.json?key=$_apiKey&q=$location&days=$days&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Forecast API response: $data');

        // Check if forecast data exists
        if (data['forecast'] == null ||
            data['forecast']['forecastday'] == null) {
          print('Warning: Forecast data is missing or malformed for $location');
          return [];
        }

        final List<dynamic> forecastDays = data['forecast']['forecastday'];

        if (forecastDays.isEmpty) {
          print('Warning: No forecast days returned for $location');
          return [];
        }

        final List<WeatherData> result = [];

        for (var day in forecastDays) {
          try {
            print('Processing forecast day: ${day['date']}');
            result.add(WeatherData.fromForecastDay(day, data['location']));
          } catch (e) {
            print('Error parsing forecast day: $e');
            // Continue with other days even if one fails
          }
        }

        return result;
      } else {
        print(
            'Failed to load forecast data: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forecast data: $e');
      throw Exception('Error fetching forecast data: $e');
    }
  }

  // Removed legacy mock forecast helper to ensure only real API data is used.
  // List<WeatherData> _getMockForecast(String location, int days) { // removed
    final List<WeatherData> result = [];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.add(Duration(days: i));
      // Generate random temperature between 15 and 30 degrees
      final tempC = 15 + (i * 2) + (date.day % 5);

      result.add(WeatherData(
        location: location,
        country: 'Mock Country',
        latitude: 0,
        longitude: 0,
        tempC: tempC.toDouble(),
        tempF: (tempC * 9 / 5 + 32).toDouble(),
        condition: i == 0 ? 'Sunny' : (i == 1 ? 'Partly cloudy' : 'Cloudy'),
        conditionIcon: '',
        windKph: 10 + i.toDouble(),
        windDirection: 'N',
        humidity: 60 + i.toDouble(),
        feelsLikeC: tempC.toDouble(),
        feelsLikeF: (tempC * 9 / 5 + 32).toDouble(),
        uv: 5.0,
        lastUpdated: date,
        isDay: true,
        rawData: {},
      ));
    }

    return result;
  }

  /// Gets weather data for multiple locations
  Future<Map<String, WeatherData>> getWeatherForMultipleLocations(
      List<String> locations) async {
    final Map<String, WeatherData> results = {};

    for (final location in locations) {
      try {
        final weatherData = await getCurrentWeather(location);
        results[location] = weatherData;
      } catch (e) {
        print('Error fetching weather for $location: $e');
        // Continue with other locations even if one fails
      }
    }

    return results;
  }
}
