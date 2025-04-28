import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/cloudinary/cloudinary_service.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/models/product/product.dart';

class ProductService {
  final String apiUrl = '/api/v1/products';
  final DioClient _dioClient;
  ProductService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  /// Lấy tất cả sản phẩm
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await _dioClient.instance.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchNewProducts() async {
    final response = await _dioClient.instance.get('$apiUrl/new');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchBestSellerProducts() async {
    final response = await _dioClient.instance.get('$apiUrl/best-sellers');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPromotionProducts() async {
    final response = await _dioClient.instance.get('$apiUrl/promotions');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    try {
      final response = await _dioClient.instance
          .get(apiUrl, queryParameters: {'id': productId});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      // Upload ảnh lên Cloudinary
      final cloudinaryService = CloudinaryService();
      final imageUrl = await cloudinaryService.uploadImage(product.imgFile);

      if (imageUrl == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      // Tạo body gửi lên server
      final body = {
        'name': product.name,
        'price': product.price.toInt(),
        'productImage': imageUrl, // Link ảnh từ Cloudinary
        'description': product.description,
        'brandId': int.parse(product.brandId),
        'categoryId': int.parse(product.categoryId),
        'available': product.available,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Gửi POST request
      final response = await _dioClient.instance.post(apiUrl, data: body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      rethrow;
    }
  }
}
