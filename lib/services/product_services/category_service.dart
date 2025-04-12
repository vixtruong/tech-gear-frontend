import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  final String apiUrl = "https://10.0.2.2:5001/api/category";

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryById(String categoryId) async {
    final response = await http.get(Uri.parse('$apiUrl/$categoryId'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load category by ID');
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryByName(String categoryName) async {
    final response = await http.get(Uri.parse('$apiUrl/by-name/$categoryName'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load category by name');
    }
  }

  Future<void> addCategory(String name) async {
    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(name),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }
}
