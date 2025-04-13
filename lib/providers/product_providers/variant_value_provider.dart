import 'package:flutter/material.dart';
import 'package:techgear/models/product/variant_value.dart';
import 'package:techgear/services/product_services/variant_value_service.dart';

class VariantValueProvider with ChangeNotifier {
  final VariantValueService _service = VariantValueService();
  List<VariantValue> _variantValues = [];

  List<VariantValue> get variantValues => _variantValues;

  Future<void> fetchVariantValues() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantValues();
      _variantValues =
          fetchedData.map((data) => VariantValue.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<VariantValue?> fetchVariantValueById(String id) async {
    final varData = await _service.fetchVariantValueById(id);
    return varData != null ? VariantValue.fromMap(varData) : null;
  }

  Future<VariantValue?> fetchVariantValueByName(String name) async {
    final varData = await _service.fetchVariantValueByName(name);
    return varData != null ? VariantValue.fromMap(varData) : null;
  }

  Future<void> fetchVariantValuesByOptionId(String optionId) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantValuesByOptionId(optionId);
      _variantValues =
          fetchedData.map((data) => VariantValue.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> addVariantValue(VariantValue item) async {
    await _service.addVariantValue(item);
    await fetchVariantValues();
  }

  Future<void> deleteVariantValue(String id) async {
    await _service.deleteVariantValue(id);
    await fetchVariantValues();
  }
}
