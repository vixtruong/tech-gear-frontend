import 'package:dio/dio.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/services/google_services/google_drive_service.dart';

class ProductService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/v1/products';

  /// Lấy tất cả sản phẩm
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await _dio.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchNewProducts() async {
    final response = await _dio.get('$apiUrl/new');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchBestSellerProducts() async {
    final response = await _dio.get('$apiUrl/best-sellers');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPromotionProducts() async {
    final response = await _dio.get('$apiUrl/promotions');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    try {
      final response =
          await _dio.get(apiUrl, queryParameters: {'id': productId});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final driveService = GoogleDriveService();
      await driveService.init();
      final fileId = await driveService.uploadFile(product.imgFile);
      driveService.dispose();

      final imageUrl = 'https://lh3.googleusercontent.com/d/$fileId=w300';

      final body = {
        'name': product.name,
        'price': product.price.toInt(),
        'productImage': imageUrl,
        'description': product.description,
        'brandId': int.parse(product.brandId),
        'categoryId': int.parse(product.categoryId),
        'available': product.available,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await _dio.post(apiUrl, data: body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      rethrow;
    }
  }
}
