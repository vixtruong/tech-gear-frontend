import 'package:flutter/material.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/product_services/category_service.dart';

import '../../models/product/category.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  CategoryProvider(this._sessionProvider)
      : _service = CategoryService(_sessionProvider);
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      List<Map<String, dynamic>> fetchedData = await _service.fetchCategories();
      _categories = fetchedData.map((data) => Category.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }

    notifyListeners();
  }

  Future<Category?> fetchCategoryById(String categoryId) async {
    final categoryData = await _service.fetchCategoryById(categoryId);
    return categoryData != null ? Category.fromMap(categoryData) : null;
  }

  Future<Category?> fetchCategoryByName(String categoryName) async {
    final categoryData = await _service.fetchCategoryByName(categoryName);
    return categoryData != null ? Category.fromMap(categoryData) : null;
  }

  Future<void> addCategory(String category) async {
    await _service.addCategory(category);
    await fetchCategories();
  }
}
