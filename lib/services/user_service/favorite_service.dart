import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class FavoriteService {
  final String apiUrl = '/api/v1/favorites';
  final DioClient _dioClient;

  FavoriteService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<int>> fetchProductFavorite(String userId) async {
    final response = await _dioClient.instance.get('$apiUrl/$userId');
    final List data = response.data;
    return data.whereType<int>().toList(); // đảm bảo là List<int>
  }

  Future<bool> addFavorite(String userId, String productId) async {
    try {
      final response = await _dioClient.instance.post(
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
      final response = await _dioClient.instance.delete(
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

  Future<bool> isProductFavorite(String userId, String productId) async {
    try {
      final response = await _dioClient.instance.put(
        '$apiUrl/is-favorite',
        data: {
          'userId': int.parse(userId),
          'productId': int.parse(productId),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
