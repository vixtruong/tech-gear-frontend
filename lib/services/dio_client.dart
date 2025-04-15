import 'package:dio/dio.dart';
import 'package:techgear/services/auth_service/session_service.dart';
import '../environment.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: Environment.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await SessionService.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final retryRequest = error.requestOptions;
            final newAccess = await SessionService.getAccessToken();
            retryRequest.headers['Authorization'] = 'Bearer $newAccess';
            final cloned = await _dio.fetch(retryRequest);
            return handler.resolve(cloned);
          }
        }
        return handler.next(error);
      },
    ));

  static Dio get instance => _dio;

  static Future<bool> _refreshToken() async {
    final refresh = await SessionService.getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await _dio.post('/api/auth/refresh', data: {
        'refreshToken': refresh,
      });

      final data = response.data;
      await SessionService.saveSessions(
          data['accessToken'], data['refreshToken']);
      return true;
    } catch (_) {
      await SessionService.clearSessions();
      return false;
    }
  }
}
