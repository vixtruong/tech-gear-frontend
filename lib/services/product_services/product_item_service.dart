import 'package:dio/dio.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/services/dio_client.dart';
import 'package:techgear/services/google_services/google_drive_service.dart';

class ProductItemService {
  final Dio _dio = DioClient.instance;
  final String apiUrl = '/api/v1/productitems';

  Future<List<Map<String, dynamic>>> fetchProductItems() async {
    final response = await _dio.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductItemsByProductId(
      String productId) async {
    final response = await _dio.get('$apiUrl/by-productId/$productId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchProductItemById(
      String productItemId) async {
    try {
      final response = await _dio.get('$apiUrl/$productItemId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> addProductItem(ProductItem productItem) async {
    try {
      final driveService = GoogleDriveService();
      await driveService.init();
      final fileId = await driveService.uploadFile(productItem.imgFile);
      driveService.dispose();

      final imageUrl = 'https://lh3.googleusercontent.com/d/$fileId=w300';

      final body = {
        'sku': productItem.sku,
        'price': productItem.price.toInt(),
        'productImage': imageUrl,
        'qtyInStock': productItem.quantity,
        'productId': int.parse(productItem.productId),
        'available': productItem.available,
        'createAt': DateTime.now().toIso8601String(),
      };

      final response = await _dio.post('$apiUrl/add', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to add product item');
      }
    } catch (e) {
      return null;
    }
  }
}
