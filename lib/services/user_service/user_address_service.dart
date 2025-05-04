import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class UserAddressService {
  final String apiUrl = '/api/v1/addresses';
  final DioClient _dioClient;

  UserAddressService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<Map<String, dynamic>>?> fetchUserAddresses(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$userId');
      final List data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to fetch addresses';
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> addUserAddress(Map<String, dynamic> dto) async {
    try {
      final response = await _dioClient.instance.post('$apiUrl/add', data: dto);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to add address';
      throw Exception(msg);
    }
  }

  Future<void> updateUserAddress(int id, Map<String, dynamic> dto) async {
    try {
      await _dioClient.instance.put('$apiUrl/update/$id', data: dto);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to update address';
      throw Exception(msg);
    }
  }

  Future<void> deleteUserAddress(int id) async {
    try {
      await _dioClient.instance.delete('$apiUrl/delete/$id');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to delete address';
      throw Exception(msg);
    }
  }

  Future<void> setDefaultAddress({
    required int userId,
    required int addressId,
  }) async {
    try {
      await _dioClient.instance.post(
        '$apiUrl/set-default',
        data: {
          'userId': userId,
          'addressId': addressId,
        },
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? 'Failed to set default address';
      throw Exception(msg);
    }
  }
}
