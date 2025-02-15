import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ConfigService {
  final FlutterSecureStorage _storage;

  ConfigService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> initialize() async {
    // Check if keys are already stored
    final hasGeminiKey =
        await _storage.containsKey(key: ApiConfig.geminiKeyName);
    final hasGoogleMapsKey =
        await _storage.containsKey(key: ApiConfig.googleMapsKeyName);
    final hasWeatherKey =
        await _storage.containsKey(key: ApiConfig.weatherKeyName);

    // Store keys if not present
    if (!hasGeminiKey) {
      await _storage.write(
        key: ApiConfig.geminiKeyName,
        value: ApiConfig.geminiApiKey,
      );
    }

    if (!hasGoogleMapsKey) {
      await _storage.write(
        key: ApiConfig.googleMapsKeyName,
        value: ApiConfig.googleMapsApiKey,
      );
    }

    if (!hasWeatherKey) {
      await _storage.write(
        key: ApiConfig.weatherKeyName,
        value: ApiConfig.weatherApiKey,
      );
    }
  }

  Future<String?> getGeminiApiKey() async {
    return _storage.read(key: ApiConfig.geminiKeyName);
  }

  Future<String?> getGoogleMapsApiKey() async {
    return _storage.read(key: ApiConfig.googleMapsKeyName);
  }

  Future<String?> getWeatherApiKey() async {
    return _storage.read(key: ApiConfig.weatherKeyName);
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
