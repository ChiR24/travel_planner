import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityService {
  final FlutterSecureStorage _storage;
  static const String _apiKeyPrefix = 'api_key_';
  static const String _userDataPrefix = 'user_data_';
  static const Duration _keyRotationInterval = Duration(days: 30);

  SecurityService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // API Key Management
  Future<void> storeApiKey(String service, String apiKey) async {
    final encryptedKey = _encryptData(apiKey);
    final timestamp = DateTime.now().toIso8601String();
    await _storage.write(
      key: '$_apiKeyPrefix${service}_key',
      value: encryptedKey,
    );
    await _storage.write(
      key: '$_apiKeyPrefix${service}_timestamp',
      value: timestamp,
    );
  }

  Future<String?> getApiKey(String service) async {
    final encryptedKey =
        await _storage.read(key: '$_apiKeyPrefix${service}_key');
    if (encryptedKey == null) return null;

    final timestamp = await _storage.read(
      key: '$_apiKeyPrefix${service}_timestamp',
    );
    if (timestamp != null) {
      final storedDate = DateTime.parse(timestamp);
      if (DateTime.now().difference(storedDate) > _keyRotationInterval) {
        // Key needs rotation
        return null;
      }
    }

    return _decryptData(encryptedKey);
  }

  // Sensitive Data Management
  Future<void> storeUserData(String userId, Map<String, dynamic> data) async {
    final jsonData = jsonEncode(data);
    final encryptedData = _encryptData(jsonData);
    await _storage.write(
      key: '$_userDataPrefix$userId',
      value: encryptedData,
    );
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final encryptedData = await _storage.read(key: '$_userDataPrefix$userId');
    if (encryptedData == null) return null;

    final jsonData = _decryptData(encryptedData);
    return jsonDecode(jsonData);
  }

  // Data Sanitization
  String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input.replaceAll(RegExp(r'[<>(){}[\]\\\/]'), '');
  }

  Map<String, dynamic> sanitizeJson(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is String) {
        return MapEntry(key, sanitizeInput(value));
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, sanitizeJson(value));
      }
      if (value is List) {
        return MapEntry(
          key,
          value.map((e) => e is String ? sanitizeInput(e) : e).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  // Basic encryption/decryption
  // Note: In a production environment, use more sophisticated encryption
  String _encryptData(String data) {
    final key = utf8.encode(
        'your_encryption_key'); // Use environment variable in production
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return '${base64.encode(bytes)}.$digest';
  }

  String _decryptData(String encryptedData) {
    final parts = encryptedData.split('.');
    if (parts.length != 2) throw Exception('Invalid encrypted data format');

    final data = base64.decode(parts[0]);
    return utf8.decode(data);
  }

  // Token Management
  Future<void> storeToken(String token, {Duration? expiry}) async {
    final expiryDate = DateTime.now().add(expiry ?? const Duration(days: 7));
    await _storage.write(
      key: 'auth_token',
      value: jsonEncode({
        'token': token,
        'expiry': expiryDate.toIso8601String(),
      }),
    );
  }

  Future<String?> getValidToken() async {
    final tokenData = await _storage.read(key: 'auth_token');
    if (tokenData == null) return null;

    final data = jsonDecode(tokenData);
    final expiry = DateTime.parse(data['expiry']);
    if (DateTime.now().isAfter(expiry)) {
      await _storage.delete(key: 'auth_token');
      return null;
    }

    return data['token'];
  }

  // Security Utilities
  bool isStrongPassword(String password) {
    return password.length >= 12 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  }

  String hashPassword(String password) {
    final salt = _generateSalt();
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '$digest.$salt';
  }

  bool verifyPassword(String password, String hashedPassword) {
    final parts = hashedPassword.split('.');
    if (parts.length != 2) return false;

    final salt = parts[1];
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '$digest.$salt' == hashedPassword;
  }

  String _generateSalt() {
    final random = List<int>.generate(
        32, (i) => DateTime.now().microsecondsSinceEpoch % 256);
    return base64.encode(random);
  }

  // Clear sensitive data
  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
  }
}
