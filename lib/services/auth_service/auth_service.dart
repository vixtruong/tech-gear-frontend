import 'package:dio/dio.dart';
import 'package:techgear/dtos/login_request_dto.dart';
import 'package:techgear/dtos/register_request_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/services/order_service/cart_service.dart';

class AuthService {
  final String apiUrl = '/api/v1/auth';
  final DioClient _dioClient;
  final CartService _cartService;
  final SessionProvider _sessionProvider;

  AuthService(this._sessionProvider, this._cartService)
      : _dioClient = DioClient(_sessionProvider);

  Future<Map<String, dynamic>?> login(LoginRequestDto request) async {
    try {
      final response = await _dioClient.instance.post(
        '$apiUrl/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('AuthService: Login successful: ${response.data}');
        return response.data;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Unknown error';
      print('AuthService: Login failed: $msg');
      throw Exception('Login failed: $msg');
    } catch (e) {
      print('AuthService: Unexpected error during login: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequestDto request) async {
    try {
      final response = await _dioClient.instance.post(
        '$apiUrl/register',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('AuthService: Registration successful: ${response.data}');
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Register failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Unknown error';
      print('AuthService: Registration failed: $msg');
      throw Exception('Register failed: $msg');
    } catch (e) {
      print('AuthService: Unexpected error during registration: $e');
      throw Exception('Register failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = _sessionProvider.refreshToken;
      final userId = _sessionProvider.userId;
      final response = await _dioClient.instance.post(
        '$apiUrl/logout',
        data: {'userId': int.parse(userId ?? ''), 'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _cartService.clearCart(_sessionProvider);
        await _sessionProvider.clearSession();
        print('AuthService: Logout successful');
      } else {
        throw Exception('Logout failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'AuthService: Logout failed: ${e.response?.data['message'] ?? e.message}');
      await _cartService.clearCart(_sessionProvider);
      await _sessionProvider.clearSession();
      rethrow;
    } catch (e) {
      print('AuthService: Unexpected error during logout: $e');
      await _cartService.clearCart(_sessionProvider);
      await _sessionProvider.clearSession();
      rethrow;
    }
  }

  Future<bool> isCustomerLogin() async {
    final userId = _sessionProvider.userId;
    final userRole = _sessionProvider.role;

    final isLoggedIn = userId != null && userRole == "Customer";
    print(
        'AuthService: isCustomerLogin: $isLoggedIn (userId: $userId, role: $userRole)');
    return isLoggedIn;
  }

  Future<void> sendOtp(String email) async {
    try {
      final response = await _dioClient.instance.post(
        '$apiUrl/otp/request',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        print('AuthService: OTP sent successfully');
      } else {
        throw Exception(
            'OTP request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Unknown error';
      print('AuthService: OTP request failed: $msg');
      throw Exception('OTP request failed: $msg');
    } catch (e) {
      print('AuthService: Unexpected error during OTP request: $e');
      throw Exception('OTP request failed: $e');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '$apiUrl/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Reset password failed with status: ${response.statusCode}');
      }

      print('AuthService: Password reset successful');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Unknown error';
      print('AuthService: Reset password failed: $msg');
      throw Exception('Reset password failed: $msg');
    } catch (e) {
      print('AuthService: Unexpected error during reset password: $e');
      throw Exception('Reset password failed: $e');
    }
  }
}
