import 'package:flutter/material.dart';
import 'package:techgear/dtos/loyalty_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/user_service/loyalty_service.dart';

class LoyaltyProvider with ChangeNotifier {
  final LoyaltyService _loyaltyService;
  List<LoyaltyDto> _loyalties = [];
  bool _isLoading = false;
  String? _error;

  LoyaltyProvider(SessionProvider sessionProvider)
      : _loyaltyService = LoyaltyService(sessionProvider);

  List<LoyaltyDto> get loyalties => _loyalties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLoyalties(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _loyaltyService.fetchLoyalties(userId);
      _loyalties = data.map((e) => LoyaltyDto.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
