import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';

class BrandService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/brand';

  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final response = await _dio.get('$apiUrl/all');
    final List data = response.data;

    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchBrandById(String brandId) async {
    try {
      final response = await _dio.get('$apiUrl/$brandId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchBrandByName(String brandName) async {
    try {
      final response = await _dio.get('$apiUrl/by-name/$brandName');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> addBrand(String brandName) async {
    final response = await _dio.post(
      '$apiUrl/add',
      data: brandName,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add brand');
    }
  }
}
