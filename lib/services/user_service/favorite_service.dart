import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';

class FavoriteService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = 'api/v1/favorites';

  Future<List<Map<String, dynamic>>> fetchProductFavorite(String userId) async {
    final response = await _dio.get('$apiUrl/user/$userId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<bool> addFavorite(String userId, String productId) async {
    try {
      final response = await _dio.post(
        '$apiUrl/add',
        data: {
          'userId': int.parse(userId),
          'productId': int.parse(productId),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 409) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String productId) async {
    try {
      final response = await _dio.delete(
        '$apiUrl/delete',
        data: {
          'userId': int.parse(userId),
          'productId': int.parse(productId),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 409) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
