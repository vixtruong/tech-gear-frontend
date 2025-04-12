import 'package:flutter/material.dart';
import 'package:techgear/services/product_services/category_service.dart';

import '../../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      List<Map<String, dynamic>> fetchedData = await _service.fetchCategories();
      _categories = fetchedData
          .map((data) => Category.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }

    notifyListeners();
  }

  Future<Category?> fetchCategoryById(String categoryId) async {
    final categoryData = await _service.fetchCategoryById(categoryId);
    return categoryData != null
        ? Category.fromMap(categoryData, categoryId)
        : null;
  }

  Future<Category?> fetchCategoryByName(String categoryName) async {
    final categoryData = await _service.fetchCategoryByName(categoryName);
    return categoryData != null
        ? Category.fromMap(categoryData, categoryData['id'])
        : null;
  }

  Future<void> addCategory(String category) async {
    await _service.addCategory(category);
    await fetchCategories();
  }
}
