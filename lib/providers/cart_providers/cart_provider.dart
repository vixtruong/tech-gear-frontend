import 'package:flutter/material.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/services/cart_service/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price! * item.quantity);

  Future<void> loadCartFromStorage() async {
    try {
      final rawList = await _cartService.loadCart();
      _items = rawList.map((map) => CartItem.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> addItem(CartItem newItem) async {
    try {
      await _cartService.addItemCart(
        int.parse(newItem.productItemId),
        quantity: newItem.quantity,
      );
      await loadCartFromStorage(); // Reload to sync UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String productItemId, int newQuantity) async {
    try {
      final index =
          _items.indexWhere((item) => item.productItemId == productItemId);
      if (index >= 0 && newQuantity > 0) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        await _cartService.saveCart([_items[index].toMap()]);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeItem(String productItemId) async {
    try {
      await _cartService.removeItemCart(int.parse(productItemId));
      await loadCartFromStorage(); // Reload to sync UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
