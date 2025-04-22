import 'package:flutter/material.dart';
import 'package:techgear/dtos/login_request_dto.dart';
import 'package:techgear/dtos/register_request_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/auth_service/auth_service.dart';
import 'package:techgear/services/order_service/cart_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(SessionProvider sessionProvider, CartService cartService)
      : _authService = AuthService(sessionProvider, cartService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequestDto(email: email, password: password),
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> register(RegisterRequestDto request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _authService.register(request);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _errorMessage = null;
    try {
      await _authService.logout();
    } catch (e) {
      _errorMessage = 'Đăng xuất thất bại: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<bool> isCustomerLogin() async {
    return await _authService.isCustomerLogin();
  }
}
