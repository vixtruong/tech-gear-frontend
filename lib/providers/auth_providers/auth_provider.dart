import 'package:flutter/foundation.dart';
import 'package:techgear/dtos/login_request_dto.dart';
import 'package:techgear/dtos/register_request_dto.dart';
import 'package:techgear/services/auth_service/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.login(
        LoginRequestDto(email: email, password: password),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequestDto request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(request);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  Future<bool> isCustomerLogin() async {
    return await _authService.isCustomerLogin();
  }
}
