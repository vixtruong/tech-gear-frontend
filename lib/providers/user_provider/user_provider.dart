import 'package:flutter/material.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/user_service/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  final SessionProvider _sessionProvider;

  UserProvider(this._sessionProvider)
      : _userService = UserService(_sessionProvider);

  int? _userId;
  int _loyaltyPoints = 0;
  bool _isLoading = false;

  int? get userId => _userId;
  int get loyaltyPoints => _loyaltyPoints;
  bool get isLoading => _isLoading;

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
    print('UserProvider: User ID set to $id');
  }

  /// Fetch current loyalty points from the server
  Future<void> fetchLoyaltyPoints() async {
    // Use SessionProvider to get userId if not set
    if (_userId == null && _sessionProvider.userId != null) {
      _userId = int.tryParse(_sessionProvider.userId!);
    }

    if (_userId == null) {
      print('UserProvider: Cannot fetch loyalty points, userId is null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final points = await _userService.getUserPoints(_userId!);
      _loyaltyPoints = points;
      print('UserProvider: Fetched loyalty points: $_loyaltyPoints');
    } catch (e) {
      print('UserProvider: Failed to fetch loyalty points: $e');
      rethrow; // Allow caller to handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deduct points after placing an order (update server and local state)
  Future<void> usePoints(int usedPoints) async {
    if (_userId == null) {
      print('UserProvider: Cannot use points, userId is null');
      return;
    }

    if (usedPoints > _loyaltyPoints) {
      print(
          'UserProvider: Insufficient loyalty points. Requested: $usedPoints, Available: $_loyaltyPoints');
      throw Exception('Insufficient loyalty points');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUserPoints(_userId!, usedPoints);
      _loyaltyPoints -= usedPoints;
      print(
          'UserProvider: Used $usedPoints points, remaining: $_loyaltyPoints');
    } catch (e) {
      print('UserProvider: Failed to use points: $e');
      rethrow; // Allow caller to handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset provider when logging out
  void resetUser() {
    _userId = null;
    _loyaltyPoints = 0;
    _isLoading = false;
    notifyListeners();
    print('UserProvider: User data reset');
  }
}
