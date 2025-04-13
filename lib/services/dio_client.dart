import 'package:dio/dio.dart';
import 'package:techgear/services/auth_service/token_service.dart';
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
        final accessToken = await TokenStorageService.getAccessToken();
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
            final newAccess = await TokenStorageService.getAccessToken();
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
    final refresh = await TokenStorageService.getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refresh,
      });

      final data = response.data;
      await TokenStorageService.saveTokens(
          data['accessToken'], data['refreshToken']);
      return true;
    } catch (_) {
      await TokenStorageService.clearTokens();
      return false;
    }
  }
}
