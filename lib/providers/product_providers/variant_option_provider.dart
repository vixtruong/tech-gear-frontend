import 'package:flutter/material.dart';
import 'package:techgear/models/variant_option.dart';
import 'package:techgear/services/product_services/variant_option_service.dart';

class VariantOptionProvider with ChangeNotifier {
  final VariantOptionService _service = VariantOptionService();
  List<VariantOption> _variantOptions = [];
  String? _selectedCategoryId;

  List<VariantOption> get variantOptions => _selectedCategoryId == null
      ? _variantOptions
      : _variantOptions
          .where((option) => option.categoryId == _selectedCategoryId)
          .toList();

  String? get selectedCategoryId => _selectedCategoryId;

  Future<void> fetchVariantOptions() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantOptions();
      _variantOptions = fetchedData
          .map((data) => VariantOption.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<VariantOption?> fetchVariantOptionById(String id) async {
    final varData = await _service.fetchVariantOptionById(id);
    return varData != null ? VariantOption.fromMap(varData, id) : null;
  }

  Future<VariantOption?> fetchVariantOptionByName(String name) async {
    final varData = await _service.fetchVariantOptionByName(name);
    return varData != null
        ? VariantOption.fromMap(varData, varData['id'])
        : null;
  }

  Future<void> fetchVariantOptionsByCateId(String cateId) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantOptionsByCateId(cateId);
      _variantOptions = fetchedData
          .map((data) => VariantOption.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> addVariantOption(VariantOption item) async {
    await _service.addVariantOption(item);
    await fetchVariantOptions();
  }
}
