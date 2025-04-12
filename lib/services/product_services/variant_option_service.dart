import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techgear/models/variant_option.dart';

class VariantOptionService {
  final String apiUrl = 'https://10.0.2.2:5001/api/variation';

  Future<List<Map<String, dynamic>>> fetchVariantOptions() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch variant options');
    }
  }

  Future<Map<String, dynamic>?> fetchVariantOptionById(String id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch variant option by ID');
    }
  }

  Future<Map<String, dynamic>?> fetchVariantOptionByName(String name) async {
    final response = await http.get(Uri.parse('$apiUrl/by-name/$name'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch variant option by name');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVariantOptionsByCateId(
      String cateId) async {
    final response = await http.get(Uri.parse('$apiUrl/by-categoryId/$cateId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch variant options by category ID');
    }
  }

  Future<void> addVariantOption(VariantOption option) async {
    final body = jsonEncode({
      'name': option.name,
      'categoryId': option.categoryId,
      'createdAt': DateTime.now().toIso8601String() // nếu cần
    });

    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add variant option');
    }
  }
}
