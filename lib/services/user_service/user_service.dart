import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:techgear/dtos/edit_profile_dto.dart';
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

  Future<Map<String, dynamic>> getUser(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$userId');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Create user failed';
      throw Exception(msg);
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

  Future<bool> updateUser(EditProfileDto dto) async {
    try {
      final response = await _dioClient.instance.put(
        '$apiUrl/edit',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Update failed with status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Lỗi kết nối máy chủ';
      debugPrint('DioException: $msg');
      throw Exception(msg);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Đã xảy ra lỗi không xác định');
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
