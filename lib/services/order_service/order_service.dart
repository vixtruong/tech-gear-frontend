import 'package:dio/dio.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/dtos/order_status_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class OrderService {
  final String apiUrl = '/api/v1/orders';
  final DioClient _dioClient;
  OrderService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<Map<String, dynamic>> fetchTotalOrders() async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/total');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Create user failed';
      throw Exception(msg);
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/get-all');
      final List data = response.data;

      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      throw Exception('Create order failed: $e');
    }
  }

  Future<bool> createOrder(OrderDto order) async {
    try {
      final response = await _dioClient.instance
          .post('$apiUrl/create', data: order.toJson());

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Create order failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Create order failed: $msg');
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersByUserId(int userId) async {
    try {
      final response =
          await _dioClient.instance.get('$apiUrl/get-by-user/$userId');
      final List data = response.data;

      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      throw Exception('Create order failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrderItemsInfoByOrderId(
      int orderId) async {
    try {
      final response = await _dioClient.instance
          .get('$apiUrl/get-order-items-info/$orderId');
      final List data = response.data;

      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      throw Exception('Create order failed: $e');
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetail(int orderId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$orderId/detail');
      final data = response.data;
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw Exception('Create order failed: $e');
    }
  }

  Future<bool> updateOrderStatus(
      int orderId, OrderStatusDto orderStatus) async {
    try {
      final response = await _dioClient.instance.put(
        '$apiUrl/update-status/$orderId',
        data: orderStatus.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Update order status failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid order ID: $msg');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Order not found: $msg');
      }
      throw Exception('Update order status failed: $msg');
    }
  }

  Future<bool> isValidRating(int orderId) async {
    try {
      final response =
          await _dioClient.instance.get('$apiUrl/is-valid-rating/$orderId');
      return response.data as bool;
    } catch (e) {
      e.toString();
      rethrow;
    }
  }
}
