import 'dart:convert';
import 'package:dio/dio.dart';
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
          merged[key]!['quantity'] =
              (merged[key]!['quantity'] as int) + (item['quantity'] as int);
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

  Future<void> removeItemCart(int productItemId) async {
    try {
      final userId = await SessionService.getUserId();

      // Update local storage
      final cart = await loadCart();
      final updated =
          cart.where((item) => item['productItemId'] != productItemId).toList();
      await saveCart(updated);

      // If user is logged in, also remove from server
      if (userId != null) {
        await _dio.delete('$apiUrl/delete', data: {
          'userId': userId,
          'productItemId': productItemId,
        });
      }
    } catch (e) {
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
