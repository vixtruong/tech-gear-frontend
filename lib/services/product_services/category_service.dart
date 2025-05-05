import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class CategoryService {
  final String apiUrl = '/api/v1/categories';
  final DioClient _dioClient;
  CategoryService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _dioClient.instance.get('$apiUrl/all');
    final List data = response.data;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchCategoryById(String categoryId) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$categoryId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryByName(String categoryName) async {
    try {
      final response =
          await _dioClient.instance.get('$apiUrl/by-name/$categoryName');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> addCategory(String name) async {
    final response = await _dioClient.instance.post(
      '$apiUrl/add',
      data: jsonEncode(name),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }
}
