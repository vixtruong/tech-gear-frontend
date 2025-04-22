import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class BrandService {
  final String apiUrl = '/api/v1/brands';
  final DioClient _dioClient;
  BrandService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);
  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final response = await _dioClient.instance.get('$apiUrl/all');
    final List data = response.data;

    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchBrandById(String brandId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$brandId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchBrandByName(String brandName) async {
    try {
      final response =
          await _dioClient.instance.get('$apiUrl/by-name/$brandName');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> addBrand(String brandName) async {
    final response = await _dioClient.instance.post(
      '$apiUrl/add',
      data: brandName,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add brand');
    }
  }
}
