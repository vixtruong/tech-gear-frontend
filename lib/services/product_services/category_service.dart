import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';

class CategoryService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/category';

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _dio.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchCategoryById(String categoryId) async {
    try {
      final response = await _dio.get('$apiUrl/$categoryId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryByName(String categoryName) async {
    try {
      final response = await _dio.get('$apiUrl/by-name/$categoryName');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> addCategory(String name) async {
    final response = await _dio.post(
      '$apiUrl/add',
      data: name,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }
}
