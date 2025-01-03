import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _jwtTokenKey = 'jwtToken';

  /// Retrieves the JWT token from secure storage.
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _jwtTokenKey);
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
  }

  /// Saves the JWT token to secure storage.
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _jwtTokenKey, value: token);
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  /// Deletes the JWT token from secure storage.
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _jwtTokenKey);
    } catch (e) {
      print("Error deleting token: $e");
    }
  }
}