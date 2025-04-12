import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techgear/models/product_config.dart';

class ProductConfigService {
  final String apiUrl = 'https://10.0.2.2:5001/api/productconfig';

  Future<List<Map<String, dynamic>>> fetchProductConfigs() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch product configs');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductConfigsByProductItemId(
      String productItemId) async {
    final response =
        await http.get(Uri.parse('$apiUrl/by-productItemId/$productItemId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch configs by productItemId');
    }
  }

  Future<void> addProductConfigs(List<ProductConfig> configs) async {
    final body = jsonEncode(configs.map((e) => e.toJson()).toList());

    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add product configs');
    }
  }
}
