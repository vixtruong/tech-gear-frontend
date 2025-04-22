import 'package:dio/dio.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class OrderService {
  final String apiUrl = '/api/v1/orders';
  final DioClient _dioClient;
  OrderService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);
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
}
