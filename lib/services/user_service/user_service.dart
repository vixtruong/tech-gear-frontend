import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class UserService {
  final String apiUrl = '/api/v1/users';
  final DioClient _dioClient;

  UserService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<String?> getUserName(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$userId/name');

      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  /// Gọi API tạo user mới
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response =
          await _dioClient.instance.post('$apiUrl/create', data: userData);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Create user failed';
      throw Exception(msg);
    }
  }

  /// Lấy điểm tích lũy hiện tại của user
  Future<int> getUserPoints(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$userId/points');
      return response.data is int
          ? response.data
          : int.parse(response.data.toString());
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to fetch points';
      throw Exception(msg);
    }
  }

  /// Cập nhật (trừ) điểm của user sau khi đặt hàng
  Future<void> updateUserPoints(int userId, int usedPoints) async {
    try {
      await _dioClient.instance.put('$apiUrl/$userId/points', data: usedPoints);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to update points';
      throw Exception(msg);
    }
  }
}
