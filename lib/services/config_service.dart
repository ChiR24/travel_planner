import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigService {
  static const String _geminiApiKey = 'GEMINI_API_KEY';
  static const String _googleMapsApiKey = 'Your_Api_Key';
  static const String _weatherApiKey = 'WEATHER_API_KEY';

  final FlutterSecureStorage _storage;

  ConfigService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> initialize() async {
    // Check if keys are already stored
    final hasGeminiKey = await _storage.containsKey(key: _geminiApiKey);
    final hasGoogleMapsKey = await _storage.containsKey(key: _googleMapsApiKey);
    final hasWeatherKey = await _storage.containsKey(key: _weatherApiKey);

    // Store keys if not present
    if (!hasGeminiKey) {
      await _storage.write(
        key: _geminiApiKey,
        value: 'Your_Api_Key',
      );
    }

    if (!hasGoogleMapsKey) {
      await _storage.write(
        key: _googleMapsApiKey,
        value: 'Your_Api_Key',
      );
    }

    if (!hasWeatherKey) {
      await _storage.write(
        key: _weatherApiKey,
        value: '8d9e8935c5b6f0e7c5f83d4c6d62e282', // OpenWeatherMap API key
      );
    }
  }

  Future<String?> getGeminiApiKey() async {
    return _storage.read(key: _geminiApiKey);
  }

  Future<String?> getGoogleMapsApiKey() async {
    return _storage.read(key: _googleMapsApiKey);
  }

  Future<String?> getWeatherApiKey() async {
    return _storage.read(key: _weatherApiKey);
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    await _storage.write(key: _geminiApiKey, value: apiKey);
  }

  Future<void> setGoogleMapsApiKey(String apiKey) async {
    await _storage.write(key: _googleMapsApiKey, value: apiKey);
  }

  Future<void> setWeatherApiKey(String apiKey) async {
    await _storage.write(key: _weatherApiKey, value: apiKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Get the Google Maps API key
  static String get googleMapsApiKey => _googleMapsApiKey;

  // Validate configuration
  static bool validateConfig() {
    if (_googleMapsApiKey.isEmpty ||
        _googleMapsApiKey == 'GOOGLE_MAPS_API_KEY') {
      print('WARNING: Google Maps API key is not configured.');
      print('Please update the _googleMapsApiKey in config_service.dart');
      return false;
    }
    return true;
  }
}
