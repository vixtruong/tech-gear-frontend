import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class CartService {
  final String _cartKey = 'cart_items';
  final DioClient _dioClient;
  final String apiUrl = '/api/v1/carts';

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

  Future<List<Map<String, dynamic>>> loadCartFromServer(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$userId');
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

  Future<void> addItemCart(int userId, int productItemId,
      {required int quantity}) async {
    try {
      final body = {
        'userId': userId,
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

  Future<void> updateCart(
      int userId, List<Map<String, dynamic>> cartItems) async {
    try {
      final body = {
        'userId': userId,
        'cartItems': cartItems
            .map((item) => {
                  'productItemId': item['productItemId'],
                  'quantity': item['quantity'],
                })
            .toList(),
      };
      print('CartService: Updating cart with body: $body');
      await _dioClient.instance.post('$apiUrl/update', data: body);
      print('CartService: Cart updated successfully for userId: $userId');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to update cart';
      print('CartService: Error updating cart: $msg');
      throw Exception(msg);
    }
  }

  Future<void> updateQuantity(
      int userId, int productItemId, int quantity) async {
    try {
      final body = {
        'userId': userId,
        'productItemId': productItemId,
        'quantity': quantity,
      };
      print('CartService: Updating quantity with body: $body');
      await _dioClient.instance.put('$apiUrl/update-quantity', data: body);
      print(
          'CartService: Quantity updated successfully for productItemId: $productItemId');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to update quantity';
      print('CartService: Error updating quantity: $msg');
      throw Exception(msg);
    }
  }

  Future<void> removeItemCart(int userId, int productItemId) async {
    try {
      await _dioClient.instance.delete(
        '$apiUrl/delete/$productItemId',
        data: {
          'userId': userId,
          'productItemId': productItemId,
        },
      );
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
