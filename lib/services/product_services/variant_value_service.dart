import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techgear/models/variant_value.dart';

class VariantValueService {
  final String apiUrl = 'https://10.0.2.2:5001/api/variationoption';

  Future<List<Map<String, dynamic>>> fetchVariantValues() async {
    final response = await http.get(Uri.parse('$apiUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch variant values');
    }
  }

  Future<Map<String, dynamic>?> fetchVariantValueById(String id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch variant value by ID');
    }
  }

  Future<Map<String, dynamic>?> fetchVariantValueByName(String name) async {
    final response = await http.get(Uri.parse('$apiUrl/by-value/$name'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch variant value by name');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVariantValuesByOptionId(
      String optionId) async {
    final response =
        await http.get(Uri.parse('$apiUrl/by-variationId/$optionId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to fetch variant values by option ID');
    }
  }

  Future<void> addVariantValue(VariantValue value) async {
    final body = jsonEncode({
      'value': value.name,
      'variationId': int.parse(value.variantOptionId),
    });

    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add variant value');
    }
  }

  Future<void> deleteVariantValue(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete variant value');
    }
  }
}
