import 'package:dio/dio.dart';
import 'package:techgear/dtos/login_request_dto.dart';
import 'package:techgear/dtos/register_request_dto.dart';
import 'package:techgear/services/auth_service/session_service.dart';
import 'package:techgear/services/cart_service/cart_service.dart';
import 'package:techgear/services/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/v1/auth';

  Future<void> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post('$apiUrl/login', data: request.toJson());

      if (response.statusCode == 200) {
        final data = response.data;

        await SessionService.saveSessions(
          data['accessToken'],
          data['refreshToken'],
        );
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Unknown error';
      throw Exception('Login failed: $msg');
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequestDto request) async {
    try {
      final response =
          await _dio.post('$apiUrl/register', data: request.toJson());

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Unknown error';
      throw Exception('Login failed: $msg');
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await SessionService.getRefreshToken();

      final response = await _dio.post(
        '$apiUrl/logout',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await SessionService.clearSessions();
        await CartService.clearCart();
      }
    } on DioException catch (e) {
      e.toString();
      await SessionService.clearSessions();
    } catch (e) {
      await SessionService.clearSessions();
    }
  }

  Future<bool> isCustomerLogin() async {
    final userId = await SessionService.getUserId();
    final userRole = await SessionService.getRole();

    return userId != null && userRole == "Customer";
  }
}
