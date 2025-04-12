import 'dart:convert';
import 'package:http/http.dart' as http;

class BrandService {
  final String apiUrl = "https://10.0.2.2:5001/api/brand";

  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  Future<Map<String, dynamic>?> fetchBrandById(String brandId) async {
    final response = await http.get(Uri.parse('$apiUrl/$brandId'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load brand by ID');
    }
  }

  Future<Map<String, dynamic>?> fetchBrandByName(String brandName) async {
    final response = await http.get(Uri.parse('$apiUrl/by-name/$brandName'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load brand by name');
    }
  }

  Future<void> addBrand(String brandName) async {
    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(brandName),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add brand');
    }
  }
}
