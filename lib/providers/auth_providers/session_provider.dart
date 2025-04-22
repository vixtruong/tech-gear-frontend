import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _role;
  bool _isSessionLoaded = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get role => _role;
  bool get isLoggedIn => _userId != null && _accessToken != null;
  bool get isSessionLoaded => _isSessionLoaded;

  Future<void> loadSession() async {
    if (_isSessionLoaded) {
      print('Session already loaded, skipping');
      return;
    }

    try {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      final userId = await _storage.read(key: 'user_id');
      final role = await _storage.read(key: 'role');

      // Only set accessToken if it's valid and not expired
      if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
        _accessToken = accessToken;
      } else {
        _accessToken = null;
      }

      _refreshToken = refreshToken;
      _userId = userId;
      _role = role;
      _isSessionLoaded = true;

      print(
          'Session loaded: accessToken=$_accessToken, userId=$_userId, role=$_role');
      notifyListeners();
    } catch (e) {
      print('Error loading session: $e');
      _isSessionLoaded = false;
    }
  }

  Future<void> saveSession(String accessToken, String refreshToken) async {
    try {
      // Save tokens to secure storage
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);

      // Decode JWT to extract userId and role
      final decoded = JwtDecoder.decode(accessToken);
      final userId = decoded['nameid'] ?? decoded['sub'];
      final role = decoded['role'];

      // Save userId and role
      await _storage.write(key: 'user_id', value: userId.toString());
      await _storage.write(key: 'role', value: role.toString());

      // Update in-memory state
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _userId = userId.toString();
      _role = role.toString();
      _isSessionLoaded = true;

      print(
          'Session saved: accessToken=$accessToken, userId=$userId, role=$role');
      notifyListeners();
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.deleteAll();
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _role = null;
      _isSessionLoaded = false;

      print('Session cleared');
      notifyListeners();
    } catch (e) {
      print('Error clearing session: $e');
    }
  }
}
