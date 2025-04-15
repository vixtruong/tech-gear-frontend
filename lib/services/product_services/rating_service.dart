import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';

class RatingService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/v1/ratings';

  Future<Map<String, dynamic>?> fetchProductAvarageRating(int productId) async {
    try {
      var response = await _dio.get('$apiUrl/average/$productId');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
