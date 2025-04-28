import 'package:dio/dio.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/cloudinary/cloudinary_service.dart';
import 'package:techgear/services/dio_client.dart';

class ProductItemService {
  final String apiUrl = '/api/v1/productitems';
  final DioClient _dioClient;
  ProductItemService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);
  Future<List<Map<String, dynamic>>> fetchProductItems() async {
    final response = await _dioClient.instance.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductItemsByProductId(
      String productId) async {
    final response =
        await _dioClient.instance.get('$apiUrl/by-productId/$productId');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductItemsInfoByIds(
      List<int> productItemIds) async {
    final response =
        await _dioClient.instance.post('$apiUrl/by-ids/', data: productItemIds);
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchProductItemById(
      String productItemId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$productItemId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<int>> getPrice(List<int> productItemIds) async {
    try {
      final response =
          await _dioClient.instance.post('$apiUrl/price', data: productItemIds);
      if (response.data is List) {
        final List<dynamic> rawData = response.data;
        final List<int> prices = rawData.map((e) => e as int).toList();
        return prices;
      } else {
        return List.filled(productItemIds.length, 0);
      }
    } catch (e) {
      return List.filled(productItemIds.length, 0);
    }
  }

  Future<Map<String, dynamic>?> addProductItem(ProductItem productItem) async {
    try {
      final cloudinaryService = CloudinaryService();
      final imageUrl = await cloudinaryService.uploadImage(productItem.imgFile);

      if (imageUrl == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      final body = {
        'sku': productItem.sku,
        'price': productItem.price.toInt(),
        'productImage': imageUrl,
        'qtyInStock': productItem.quantity,
        'productId': int.parse(productItem.productId),
        'available': productItem.available,
        'createAt': DateTime.now().toIso8601String(),
      };

      final response =
          await _dioClient.instance.post('$apiUrl/add', data: body);

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
