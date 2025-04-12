import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techgear/models/product_item.dart';
import 'package:techgear/services/google_services/google_drive_service.dart';

class ProductItemService {
  final String apiUrl = 'https://10.0.2.2:5001/api/productitem';

  Future<List<Map<String, dynamic>>> fetchProductItems() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch product items');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductItemsByProductId(
      String productId) async {
    final response =
        await http.get(Uri.parse('$apiUrl/by-productId/$productId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch product items by product ID');
    }
  }

  Future<Map<String, dynamic>?> fetchProductItemById(
      String productItemId) async {
    final response = await http.get(Uri.parse('$apiUrl/$productItemId'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch product item by ID');
    }
  }

  Future<Map<String, dynamic>?> addProductItem(ProductItem productItem) async {
    try {
      final driveService = GoogleDriveService();
      await driveService.init();
      String? fileId = await driveService.uploadFile(productItem.imgFile);
      driveService.dispose();

      String imageUrl = "https://lh3.googleusercontent.com/d/$fileId=w300";

      final body = jsonEncode({
        'sku': productItem.sku,
        'price': productItem.price.toInt(),
        'productImage': imageUrl,
        'qtyInStock': productItem.quantity,
        'productId': int.parse(productItem.productId),
        'available': productItem.available,
        'createAt': DateTime.now().toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$apiUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add product item: ${response.body}');
      }
    } catch (e) {
      e.toString();
    }
    return null;
  }
}
