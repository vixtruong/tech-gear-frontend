import 'package:flutter/material.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/services/cart_service/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price! * item.quantity);

  Future<void> loadCartFromStorage() async {
    final rawList = await CartService.loadCart();
    _items = rawList.map((map) => CartItem.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addItem(CartItem newItem) async {
    final index = _items
        .indexWhere((item) => item.productItemId == newItem.productItemId);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + newItem.quantity,
      );
    } else {
      _items.add(newItem);
    }

    // Save only the new/updated item
    await CartService.saveCart([newItem.toMap()]);
    notifyListeners();
  }

  Future<void> updateQuantity(String productItemId, int newQuantity) async {
    final index =
        _items.indexWhere((item) => item.productItemId == productItemId);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      await CartService.saveCart([_items[index].toMap()]);
      notifyListeners();
    }
  }

  Future<void> removeItem(String productItemId) async {
    _items.removeWhere((item) => item.productItemId == productItemId);
    await CartService.saveCart(_items.map((item) => item.toMap()).toList());
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items = [];
    await CartService.clearCart();
    notifyListeners();
  }
}
