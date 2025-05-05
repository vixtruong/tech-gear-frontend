import 'package:flutter/material.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/user_service/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService;

  FavoriteProvider(SessionProvider sessionProvider)
      : _favoriteService = FavoriteService(sessionProvider);

  List<int> _favorites = []; // List productId
  bool _isLoading = false;
  String? _error;

  List<int> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _favoriteService.fetchProductFavorite(userId);
      _favorites = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFavorite(String userId, String productId) async {
    final success = await _favoriteService.addFavorite(userId, productId);
    if (success) {
      await fetchFavorites(userId);
    }
    return success;
  }

  Future<bool> removeFavorite(String userId, String productId) async {
    final success = await _favoriteService.removeFavorite(userId, productId);
    if (success) {
      await fetchFavorites(userId);
    }
    return success;
  }

  Future<bool> checkIsFavorite(String userId, String productId) async {
    try {
      return await _favoriteService.isProductFavorite(userId, productId);
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
