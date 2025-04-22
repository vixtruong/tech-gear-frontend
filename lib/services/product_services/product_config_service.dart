import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/product/product_config.dart';

class ProductConfigService {
  final String apiUrl = '/api/v1/productconfigs';
  final DioClient _dioClient;
  ProductConfigService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  /// Lấy tất cả cấu hình
  Future<List<Map<String, dynamic>>> fetchProductConfigs() async {
    final response = await _dioClient.instance.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Lấy cấu hình theo productItemId
  Future<List<Map<String, dynamic>>> fetchProductConfigsByProductItemId(
      String productItemId) async {
    final response = await _dioClient.instance
        .get('$apiUrl/by-productItemId/$productItemId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Thêm danh sách cấu hình mới
  Future<void> addProductConfigs(List<ProductConfig> configs) async {
    final body = configs.map((e) => e.toJson()).toList();

    final response = await _dioClient.instance.post(
      '$apiUrl/add',
      data: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add product configs');
    }
  }
}
