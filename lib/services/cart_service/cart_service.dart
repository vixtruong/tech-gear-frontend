import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const _cartKey = 'guest_cart';

  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCart = jsonEncode(cartItems);
    await prefs.setString(_cartKey, jsonCart);
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
