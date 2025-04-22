import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class RatingService {
  final String apiUrl = '/api/v1/ratings';
  final DioClient _dioClient;

  RatingService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<Map<String, dynamic>?> fetchProductAvarageRating(int productId) async {
    try {
      var response =
          await _dioClient.instance.get('$apiUrl/average/$productId');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
