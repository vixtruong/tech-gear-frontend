import 'package:flutter/material.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/order_service/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  final SessionProvider _sessionProvider;
  List<CartItem> _items = [];

  CartProvider(this._sessionProvider)
      : _cartService = CartService(_sessionProvider);

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price! * item.quantity);

  Future<void> saveCart() async {
    final cartMap = _items
        .map((item) => {
              'productItemId': item.productItemId,
              'quantity': item.quantity,
              'price': item.price,
            })
        .toList();

    await _cartService.saveCart(cartMap);
  }

  Future<void> loadCartFromStorage() async {
    try {
      final rawList = await _cartService.loadCart();
      _items = rawList.map((map) => CartItem.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }

  Future<void> loadCartFromServer() async {
    try {
      final userId = _sessionProvider.userId;
      if (userId == null) {
        throw Exception('User ID is null');
      }
      final rawList = await _cartService.loadCartFromServer(int.parse(userId));
      _items = rawList.map((map) => CartItem.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart from server: $e');
    }
  }

  Future<void> loadCart() async {
    if (_sessionProvider.isLoggedIn) {
      await loadCartFromServer();
    } else {
      await loadCartFromStorage();
    }
  }

  Future<void> addItem(CartItem newItem) async {
    try {
      final index = _items
          .indexWhere((item) => item.productItemId == newItem.productItemId);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity + newItem.quantity,
        );
      } else {
        _items.add(newItem);
      }
      await saveCart();

      final productItemId = int.tryParse(newItem.productItemId);
      if (productItemId == null) {
        throw Exception('Invalid productItemId');
      }

      if (_sessionProvider.isLoggedIn) {
        final userId = _sessionProvider.userId;
        if (userId == null) {
          throw Exception('User ID is null');
        }
        await _cartService.addItemCart(
          int.parse(userId),
          productItemId,
          quantity: newItem.quantity,
        );
        await loadCartFromServer();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String productItemId, bool increase) async {
    try {
      final index =
          _items.indexWhere((item) => item.productItemId == productItemId);
      if (index >= 0) {
        final currentQuantity = _items[index].quantity;
        final newQuantity =
            increase ? currentQuantity + 1 : currentQuantity - 1;

        if (newQuantity < 1 || newQuantity > 99) return;
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        await saveCart();
        if (_sessionProvider.isLoggedIn) {
          final userId = _sessionProvider.userId;
          if (userId == null) {
            throw Exception('User ID is null');
          }
          await _cartService.updateQuantity(
            int.parse(userId),
            int.parse(productItemId),
            newQuantity,
          );
          await loadCartFromServer();
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> updateCartToServer() async {
    try {
      if (_sessionProvider.isLoggedIn) {
        final userId = _sessionProvider.userId;
        if (userId == null) {
          throw Exception('User ID is null');
        }
        final cartMap = _items
            .map((item) => {
                  'productItemId': int.parse(item.productItemId),
                  'quantity': item.quantity,
                })
            .toList();
        await _cartService.updateCart(int.parse(userId), cartMap);
        await loadCartFromServer();
      } else {
        await saveCart();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating cart: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String productItemId) async {
    try {
      _items.removeWhere((item) => item.productItemId == productItemId);
      await saveCart();

      final productItemIdInt = int.tryParse(productItemId);
      if (_sessionProvider.isLoggedIn && productItemIdInt != null) {
        final userId = _sessionProvider.userId;
        if (userId == null) {
          throw Exception('User ID is null');
        }
        await _cartService.removeItemCart(int.parse(userId), productItemIdInt);
        await loadCartFromServer();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing item: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart(_sessionProvider);
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }

  Future<void> syncLocalCartToServer() async {
    if (_sessionProvider.isLoggedIn) {
      final userId = _sessionProvider.userId;
      if (userId == null) {
        throw Exception('User ID is null');
      }
      for (var item in _items) {
        await _cartService.addItemCart(
          int.parse(userId),
          int.parse(item.productItemId),
          quantity: item.quantity,
        );
      }
      await _cartService.saveCart([]);
      await loadCartFromServer();
    }
  }
}
