import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techgear/services/auth_service/session_service.dart';
import 'package:techgear/services/dio_client.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final Dio _dio = DioClient.instance;
  final String apiUrl = "/api/v1/carts";
  final String _cartKey = 'guest_cart';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save cart items to local storage and optionally to server
  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    try {
      final prefs = await _getPrefs();
      final userId = await SessionService.getUserId();
      final existing = await loadCart();
      final merged = <String, Map<String, dynamic>>{
        for (var item in existing) item['productItemId'].toString(): item
      };

      for (var item in cartItems) {
        final key = item['productItemId'].toString();
        if (merged.containsKey(key)) {
          merged[key]!['quantity'] = (item['quantity'] as int);
        } else {
          merged[key] = item;
        }
      }

      // Save to local storage
      final jsonCart = jsonEncode(merged.values.toList());
      await prefs.setString(_cartKey, jsonCart);

      // If user is logged in, sync to server
      if (userId != null) {
        for (var item in merged.values) {
          await _dio.post('$apiUrl/add', data: {
            'userId': userId,
            'productItemId': item['productItemId'],
            'quantity': item['quantity'],
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  Future<void> addItemCart(int productItemId, {int quantity = 1}) async {
    try {
      final userId = await SessionService.getUserId();
      final cartItem = {'productItemId': productItemId, 'quantity': quantity};

      // Always save to local storage
      await saveCart([cartItem]);

      // If user is logged in, also save to server
      if (userId != null) {
        await _dio.post('$apiUrl/add', data: {
          'userId': userId,
          'productItemId': productItemId,
          'quantity': quantity,
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Save cart items to local storage and server after removal (overwrite, no merge)
  Future<void> _saveCartForRemove(
      List<Map<String, dynamic>> updatedCart) async {
    try {
      final prefs = await _getPrefs();
      final userId = await SessionService.getUserId();

      // Ghi đè toàn bộ danh sách giỏ hàng mới vào local storage
      final jsonCart = jsonEncode(updatedCart);
      await prefs.setString(_cartKey, jsonCart);
      debugPrint(
          'CartService: Cart updated in local storage after removal: $jsonCart');

      // Nếu user đã đăng nhập, đồng bộ với server
      if (userId != null) {
        // Gửi toàn bộ giỏ hàng mới lên server
        // Ở đây, bạn có thể cần một API để cập nhật toàn bộ giỏ hàng
        // Ví dụ: Gửi danh sách các sản phẩm còn lại
        await _dio.post('$apiUrl/update', data: {
          'userId': userId,
          'cartItems': updatedCart,
        });
        debugPrint('CartService: Cart synced to server after removal');
      }
    } catch (e) {
      debugPrint('CartService: Failed to save cart after removal: $e');
      throw Exception('Failed to save cart after removal: $e');
    }
  }

  Future<void> removeItemCart(int productItemId) async {
    try {
      final userId = await SessionService.getUserId();

      // Log để debug
      debugPrint(
          'CartService: Removing item with productItemId: $productItemId');

      // Update local storage
      final cart = await loadCart();
      final updated = cart
          .where((item) =>
              item['productItemId'].toString() != productItemId.toString())
          .toList();

      // Kiểm tra xem có sản phẩm nào bị xóa không
      if (cart.length == updated.length) {
        debugPrint(
            'CartService: No item with productItemId $productItemId found in cart');
      }

      // Lưu giỏ hàng đã cập nhật vào local storage
      await _saveCartForRemove(updated);

      // Nếu user đã đăng nhập, xóa trên server
      if (userId != null) {
        await _dio.delete('$apiUrl/delete', data: {
          'userId': userId,
          'productItemId': productItemId,
        });
        debugPrint('CartService: Item removed from server');
      }
    } catch (e) {
      debugPrint('CartService: Failed to remove item: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadCart() async {
    try {
      final prefs = await _getPrefs();
      final jsonCart = prefs.getString(_cartKey);
      if (jsonCart == null) return [];

      final List<dynamic> decoded = jsonDecode(jsonCart);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final prefs = await _getPrefs();
      final userId = await SessionService.getUserId();

      // Clear local storage
      await prefs.remove(_cartKey);

      // If user is logged in, clear server cart
      if (userId != null) {
        await _dio.delete('$apiUrl/clear', data: {'userId': userId});
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  Future<int> getNumberItemsCart() async {
    final List<Map<String, dynamic>> cart = await loadCart();

    return cart.length;
  }
}
