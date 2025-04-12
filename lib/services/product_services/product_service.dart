import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techgear/models/product.dart';
import 'package:techgear/services/google_services/google_drive_service.dart';

class ProductService {
  final String apiUrl = 'https://10.0.2.2:5001/api/product';

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    final response = await http.get(Uri.parse('$apiUrl?id=$productId'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch product');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      // Upload ảnh lên Google Drive nếu cần
      final driveService = GoogleDriveService();
      await driveService.init();
      String? fileId = await driveService.uploadFile(product.imgFile);
      driveService.dispose();

      String imageUrl = "https://lh3.googleusercontent.com/d/$fileId=w300";

      final body = jsonEncode({
        'name': product.name,
        'price': product.price.toInt(),
        'productImage': imageUrl,
        'description': product.description,
        'brandId': int.parse(product.brandId),
        'categoryId': int.parse(product.categoryId),
        'available': product.available,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      e.toString();
    }
  }
}
