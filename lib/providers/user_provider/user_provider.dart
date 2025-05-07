import 'package:flutter/material.dart';
import 'package:techgear/dtos/edit_profile_dto.dart';
import 'package:techgear/dtos/total_user_dto.dart';
import 'package:techgear/dtos/user_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/user_service/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  final SessionProvider _sessionProvider;

  UserProvider(this._sessionProvider)
      : _userService = UserService(_sessionProvider);

  int? _userId;
  UserDto? _user;
  int _loyaltyPoints = 0;
  bool _isLoading = false;

  int? get userId => _userId;
  UserDto? get user => _user;
  int get loyaltyPoints => _loyaltyPoints;
  bool get isLoading => _isLoading;

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
    print('UserProvider: User ID set to $id');
  }

  Future<bool> updateUserInfo(EditProfileDto dto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userService.updateUser(dto);
      if (success && _user != null) {
        // Cập nhật _user nếu cần
        final updatedUser = await fetchUser(_user!.id);
        if (updatedUser != null) {
          _user = updatedUser;
        }
      }
      return success;
    } catch (e) {
      print('UserProvider: Failed to update user info: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserDto?> fetchUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userService.getUser(userId);
      _user = UserDto.fromJson(data);
      _userId = userId;
      _loyaltyPoints = _user?.point ?? 0; // Đồng bộ loyaltyPoints
      print('UserProvider: Fetched user: ${_user?.fullName}');
      notifyListeners();
      return _user;
    } catch (e) {
      print('UserProvider: Failed to fetch user: $e');
      rethrow; // Để ProfileScreen xử lý lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TotalUserDto?> fetchTotalUser() async {
    try {
      final data = await _userService.getTotalUser();

      return TotalUserDto.fromJson(data);
    } catch (e) {
      rethrow; // Để ProfileScreen xử lý lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> fetchUserName(int userId) async {
    try {
      final result = await _userService.getUserName(userId);
      return result;
    } catch (e) {
      print('UserProvider: Failed to fetch user name: $e');
      return null;
    }
  }

  Future<void> fetchLoyaltyPoints() async {
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
      if (_user != null) {
        _user = _user!.copyWith(point: points); // Cập nhật point trong _user
      }
      print('UserProvider: Fetched loyalty points: $_loyaltyPoints');
      notifyListeners();
    } catch (e) {
      print('UserProvider: Failed to fetch loyalty points: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> usePoints(int usedPoints) async {
    if (_userId == null) {
      print('UserProvider: Cannot use points, userId is null');
      throw Exception('User ID is null');
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
      if (_user != null) {
        _user = _user!
            .copyWith(point: _loyaltyPoints); // Cập nhật point trong _user
      }
      print(
          'UserProvider: Used $usedPoints points, remaining: $_loyaltyPoints');
      notifyListeners();
    } catch (e) {
      print('UserProvider: Failed to use points: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetUser() {
    _userId = null;
    _user = null;
    _loyaltyPoints = 0;
    _isLoading = false;
    notifyListeners();
    print('UserProvider: User data reset');
  }
}
