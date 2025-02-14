import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/config_service.dart';

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

// Provider for Gemini API key
final geminiApiKeyProvider = FutureProvider<String?>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return configService.getGeminiApiKey();
});

// Provider for Google Maps API key
final googleMapsApiKeyProvider = FutureProvider<String?>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return configService.getGoogleMapsApiKey();
});

// Provider for OpenWeatherMap API key
final weatherApiKeyProvider = FutureProvider<String?>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return configService.getWeatherApiKey();
});
