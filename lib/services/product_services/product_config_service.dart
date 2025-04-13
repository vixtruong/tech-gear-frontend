import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/product/product_config.dart';

class ProductConfigService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/productconfig';

  /// Lấy tất cả cấu hình
  Future<List<Map<String, dynamic>>> fetchProductConfigs() async {
    final response = await _dio.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Lấy cấu hình theo productItemId
  Future<List<Map<String, dynamic>>> fetchProductConfigsByProductItemId(
      String productItemId) async {
    final response = await _dio.get('$apiUrl/by-productItemId/$productItemId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Thêm danh sách cấu hình mới
  Future<void> addProductConfigs(List<ProductConfig> configs) async {
    final body = configs.map((e) => e.toJson()).toList();

    final response = await _dio.post(
      '$apiUrl/add',
      data: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add product configs');
    }
  }
}
