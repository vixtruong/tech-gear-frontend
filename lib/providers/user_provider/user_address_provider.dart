import 'package:flutter/material.dart';
import 'package:techgear/models/user/user_address.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/user_service/user_address_service.dart';

class UserAddressProvider with ChangeNotifier {
  final UserAddressService _addressService;
  final SessionProvider _sessionProvider;

  List<UserAddress> _addresses = [];
  bool _isLoading = false;

  List<UserAddress> get addresses => _addresses;
  bool get isLoading => _isLoading;

  UserAddressProvider(this._sessionProvider)
      : _addressService = UserAddressService(_sessionProvider);

  /// Fetch all addresses of the current user
  Future<void> fetchUserAddresses() async {
    final userId = _sessionProvider.userId;

    if (userId == null) {
      print('UserAddressProvider: Cannot fetch addresses, userId is null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final rawList =
          await _addressService.fetchUserAddresses(int.parse(userId));
      _addresses = rawList?.map((e) => UserAddress.fromJson(e)).toList() ?? [];
      print('UserAddressProvider: Fetched ${_addresses.length} addresses');
    } catch (e) {
      print('UserAddressProvider: Failed to fetch addresses: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new address
  Future<void> addAddress(UserAddress address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAddressJson =
          await _addressService.addUserAddress(address.toJson());
      final newAddress = UserAddress.fromJson(newAddressJson);
      _addresses.add(newAddress);
      print('UserAddressProvider: Address added');
    } catch (e) {
      print('UserAddressProvider: Failed to add address: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing address
  Future<void> updateAddress(int id, UserAddress updatedAddress) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addressService.updateUserAddress(id, updatedAddress.toJson());
      final index = _addresses.indexWhere((addr) => addr.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }
      print('UserAddressProvider: Address updated');
    } catch (e) {
      print('UserAddressProvider: Failed to update address: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an address
  Future<void> deleteAddress(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addressService.deleteUserAddress(id);
      _addresses.removeWhere((addr) => addr.id == id);
      print('UserAddressProvider: Address deleted');
    } catch (e) {
      print('UserAddressProvider: Failed to delete address: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all user data on logout
  void resetAddresses() {
    _addresses = [];
    _isLoading = false;
    notifyListeners();
    print('UserAddressProvider: Address data reset');
  }
}
