import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class CartService {
  final String _cartKey = 'cart_items';
  final DioClient _dioClient;
  final String apiUrl = '/api/v1/cart';

  CartService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cartItems);
    await prefs.setString(_cartKey, cartJson);
    print('CartService: Saved cart to local storage: $cartJson');
  }

  Future<List<Map<String, dynamic>>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) {
      print('CartService: No cart found in local storage');
      return [];
    }
    final List<dynamic> cartList = jsonDecode(cartJson);
    print('CartService: Loaded cart from local storage: $cartList');
    return cartList.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> loadCartFromServer() async {
    try {
      final response = await _dioClient.instance.get(apiUrl);
      final List<dynamic> data = response.data;
      print('CartService: Loaded cart from server: $data');
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? 'Failed to load cart from server';
      print('CartService: Error loading cart from server: $msg');
      throw Exception(msg);
    }
  }

  Future<void> addItemCart(int productItemId, {required int quantity}) async {
    try {
      final body = {
        'productItemId': productItemId,
        'quantity': quantity,
      };
      print('CartService: Adding item with body: $body');
      await _dioClient.instance.post('$apiUrl/add', data: body);
      print('CartService: Added item to cart: $body');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to add item to cart';
      print('CartService: Error adding item to cart: $msg');
      throw Exception(msg);
    }
  }

  Future<void> removeItemCart(int productItemId) async {
    try {
      await _dioClient.instance.delete('$apiUrl/remove/$productItemId');
      print('CartService: Removed item from cart: $productItemId');
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? 'Failed to remove item from cart';
      print('CartService: Error removing item from cart: $msg');
      throw Exception(msg);
    }
  }

  Future<void> clearCart(SessionProvider sessionProvider) async {
    final userId = sessionProvider.userId;
    final prefs = await SharedPreferences.getInstance();

    if (userId != null) {
      await prefs.remove(_cartKey);
      print('CartService: Cart cleared for userId: $userId');
    } else {
      print('CartService: No userId found, skipping cart clear');
    }
  }
}
