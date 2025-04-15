import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techgear/services/auth_service/session_service.dart';
import 'package:techgear/services/dio_client.dart';

class CartService {
  static const _cartKey = 'guest_cart';

  /// Save one or more cart items
  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing local cart
    final existing = await loadCart();
    final Map<String, Map<String, dynamic>> merged = {
      for (var item in existing) item['productItemId'].toString(): item
    };

    for (var item in cartItems) {
      final key = item['productItemId'].toString();
      if (merged.containsKey(key)) {
        merged[key]!['quantity'] += item['quantity'];
      } else {
        merged[key] = item;
      }
    }

    // Save merged cart locally
    final jsonCart = jsonEncode(merged.values.toList());
    await prefs.setString(_cartKey, jsonCart);

    // If user is logged in → sync to backend
    final userId = await SessionService.getUserId();
    if (userId != null) {
      try {
        final productItemIds = cartItems
            .map((item) => item['productItemId'])
            .where((id) => id != null)
            .toList();

        await DioClient.instance.post('/api/v1/carts/add-list', data: {
          'userId': userId,
          'productItemIds': productItemIds,
        });
      } catch (e) {
        e.toString();
      }
    }
  }

  static Future<List<Map<String, dynamic>>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCart = prefs.getString(_cartKey);

    if (jsonCart != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonCart);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        e.toString();
      }
    }

    return [];
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
