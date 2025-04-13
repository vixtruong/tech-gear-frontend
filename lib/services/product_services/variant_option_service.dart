import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/product/variant_option.dart';

class VariantOptionService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/variation';

  /// Lấy tất cả variant options
  Future<List<Map<String, dynamic>>> fetchVariantOptions() async {
    final response = await _dio.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Lấy variant option theo ID
  Future<Map<String, dynamic>?> fetchVariantOptionById(String id) async {
    try {
      final response = await _dio.get('$apiUrl/$id');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Lấy variant option theo tên
  Future<Map<String, dynamic>?> fetchVariantOptionByName(String name) async {
    try {
      final response = await _dio.get('$apiUrl/by-name/$name');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Lấy variant options theo categoryId
  Future<List<Map<String, dynamic>>> fetchVariantOptionsByCateId(
      String cateId) async {
    final response = await _dio.get('$apiUrl/by-categoryId/$cateId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Thêm variant option mới
  Future<void> addVariantOption(VariantOption option) async {
    final body = {
      'name': option.name,
      'categoryId': option.categoryId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final response = await _dio.post('$apiUrl/add', data: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add variant option');
    }
  }
}
