import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveSessions(
      String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);

    final decoded = JwtDecoder.decode(accessToken);
    final userId = decoded['nameid'] ?? decoded['sub'];
    final role = decoded['role'];

    await _storage.write(key: 'user_id', value: userId.toString());
    await _storage.write(key: 'role', value: role.toString());
  }

  static Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  static Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');
  static Future<String?> getUserId() => _storage.read(key: 'user_id');
  static Future<String?> getRole() => _storage.read(key: 'role');

  static Future<void> clearSessions() async {
    await _storage.deleteAll();
  }
}
