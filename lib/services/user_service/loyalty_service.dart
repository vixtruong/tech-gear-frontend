import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class LoyaltyService {
  final String apiUrl = '/api/v1/loyalties';
  final DioClient _dioClient;

  LoyaltyService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<Map<String, dynamic>>> fetchLoyalties(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$userId/all');

      final List data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Create user failed';
      throw Exception(msg);
    }
  }
}
