import 'package:dio/dio.dart';
import 'package:techgear/models/product/rating.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class RatingService {
  final String apiUrl = '/api/v1/ratings';
  final DioClient _dioClient;

  RatingService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<Map<String, dynamic>>> fetchRatingsByProductId(
      int productId) async {
    try {
      final response =
          await _dioClient.instance.get('$apiUrl/product/$productId');

      final List data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRatingsByUserId(int userId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/user/$userId');

      final List data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

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

  Future<bool> isRated(int orderId, int productItemId) async {
    try {
      final response = await _dioClient.instance
          .get('$apiUrl/is-rated/$orderId/$productItemId');
      return response.data as bool;
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

  Future<void> addRating(Rating rating) async {
    try {
      await _dioClient.instance.post('$apiUrl/add', data: rating.toJson());
    } catch (e) {
      e.toString();
    }
  }

  Future<void> updateRating(Rating rating) async {
    try {
      await _dioClient.instance
          .put('$apiUrl/${rating.id}', data: rating.toJson());
    } catch (e) {
      e.toString();
    }
  }

  Future<void> deleteRating(Rating rating) async {
    try {
      await _dioClient.instance.delete('$apiUrl/${rating.id}');
    } catch (e) {
      e.toString();
    }
  }
}
