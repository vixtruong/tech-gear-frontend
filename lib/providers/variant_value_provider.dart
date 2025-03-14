import 'package:flutter/material.dart';
import 'package:techgear/models/variant_value.dart';
import 'package:techgear/services/variant_value_service.dart';

class VariantValueProvider with ChangeNotifier {
  final VariantValueService _service = VariantValueService();
  List<VariantValue> _variantValues = [];

  List<VariantValue> get variantValues => _variantValues;

  Future<void> fetchVariantValues() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantValues();
      _variantValues = fetchedData
          .map((data) => VariantValue.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {}
  }

  Future<VariantValue?> fetchVariantValueById(String id) async {
    final varData = await _service.fetchVariantValueById(id);
    return varData != null ? VariantValue.fromMap(varData, id) : null;
  }

  Future<VariantValue?> fetchVariantValueByName(String name) async {
    final varData = await _service.fetchVariantValueByName(name);
    return varData != null
        ? VariantValue.fromMap(varData, varData['id'])
        : null;
  }

  Future<void> fetchVariantValuesByOptionId(String optionId) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantValuesByOptionId(optionId);
      _variantValues = fetchedData
          .map((data) => VariantValue.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> addVariantValue(VariantValue item) async {
    await _service.addVariantValue(item);
    await fetchVariantValues();
  }
}
