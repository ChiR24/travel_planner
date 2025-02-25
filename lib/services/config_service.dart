import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ConfigService {
  final FlutterSecureStorage _storage;

  ConfigService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> initialize() async {
    // Always update keys with the latest values from ApiConfig
    await _storage.write(
      key: ApiConfig.geminiKeyName,
      value: ApiConfig.geminiApiKey,
    );

    await _storage.write(
      key: ApiConfig.googleMapsKeyName,
      value: ApiConfig.googleMapsApiKey,
    );

    await _storage.write(
      key: ApiConfig.weatherKeyName,
      value: ApiConfig.weatherApiKey,
    );

    // Print API keys for debugging
    print('Initialized ConfigService with:');
    print('Gemini API Key: ${ApiConfig.geminiApiKey.substring(0, 10)}...');
    print(
        'Google Maps API Key: ${ApiConfig.googleMapsApiKey.substring(0, 10)}...');
    print('Weather API Key: ${ApiConfig.weatherApiKey.substring(0, 10)}...');
    print('Use Mock Data: ${ApiConfig.useMockData}');
  }

  Future<String?> getGeminiApiKey() async {
    // Return the value directly from ApiConfig
    return ApiConfig.geminiApiKey;
  }

  Future<String?> getGoogleMapsApiKey() async {
    // Return the value directly from ApiConfig
    return ApiConfig.googleMapsApiKey;
  }

  Future<String?> getWeatherApiKey() async {
    // Return the value directly from ApiConfig
    return ApiConfig.weatherApiKey;
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    await _storage.write(key: ApiConfig.geminiKeyName, value: apiKey);
  }

  Future<void> setGoogleMapsApiKey(String apiKey) async {
    await _storage.write(key: ApiConfig.googleMapsKeyName, value: apiKey);
  }

  Future<void> setWeatherApiKey(String apiKey) async {
    await _storage.write(key: ApiConfig.weatherKeyName, value: apiKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Validate configuration
  static bool validateConfig() {
    return ApiConfig.validateKeys();
  }
}
