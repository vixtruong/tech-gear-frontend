import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import '../environment.dart';

class DioClient {
  final SessionProvider _sessionProvider;

  DioClient(this._sessionProvider) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = _sessionProvider.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await refreshToken();
          if (refreshed) {
            final newAccess = _sessionProvider.accessToken;
            final retryRequest = error.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newAccess';
            final cloned = await _dio.fetch(retryRequest);
            return handler.resolve(cloned);
          }
        }
        return handler.next(error);
      },
    ));
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: Environment.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  Dio get instance => _dio;

  bool _isRefreshing = false;

  Future<bool> refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = _sessionProvider.refreshToken;
      final userId = _sessionProvider.userId;
      if (refreshToken == null || userId == null) return false;

      final response = await _dio.post('/api/v1/auth/refresh-token', data: {
        'userId': int.parse(userId),
        'refreshToken': refreshToken,
      });

      final data = response.data;
      await _sessionProvider.saveSession(
          data['accessToken'], data['refreshToken']);

      print("Token refreshed successfully");
      return true;
    } catch (e) {
      print("Failed to refresh token: $e");
      await _sessionProvider.clearSession();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
