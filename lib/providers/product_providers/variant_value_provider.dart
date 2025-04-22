import 'package:flutter/material.dart';
import 'package:techgear/models/product/variant_value.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/product_services/variant_value_service.dart';

class VariantValueProvider with ChangeNotifier {
  final VariantValueService _service;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  VariantValueProvider(this._sessionProvider)
      : _service = VariantValueService(_sessionProvider);

  List<VariantValue> _variantValues = [];
  bool _isLoading = false;

  List<VariantValue> get variantValues => _variantValues;
  bool get isLoading => _isLoading;

  Future<void> fetchVariantValues() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantValues();
      _variantValues =
          fetchedData.map((data) => VariantValue.fromMap(data)).toList();
      print('VariantValueProvider: Fetched variant values: $_variantValues');
      notifyListeners();
    } catch (e) {
      print('VariantValueProvider: Failed to fetch variant values: $e');
      rethrow; // Allow caller to handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<VariantValue?> fetchVariantValueById(String id) async {
    try {
      final varData = await _service.fetchVariantValueById(id);
      final variantValue =
          varData != null ? VariantValue.fromMap(varData) : null;
      print(
          'VariantValueProvider: Fetched variant value by ID $id: $variantValue');
      return variantValue;
    } catch (e) {
      print(
          'VariantValueProvider: Failed to fetch variant value by ID $id: $e');
      rethrow;
    }
  }

  Future<VariantValue?> fetchVariantValueByName(String name) async {
    try {
      final varData = await _service.fetchVariantValueByName(name);
      final variantValue =
          varData != null ? VariantValue.fromMap(varData) : null;
      print(
          'VariantValueProvider: Fetched variant value by name $name: $variantValue');
      return variantValue;
    } catch (e) {
      print(
          'VariantValueProvider: Failed to fetch variant value by name $name: $e');
      rethrow;
    }
  }

  Future<void> fetchVariantValuesByOptionId(String optionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchVariantValuesByOptionId(optionId);
      _variantValues =
          fetchedData.map((data) => VariantValue.fromMap(data)).toList();
      print(
          'VariantValueProvider: Fetched variant values by option ID $optionId: $_variantValues');
      notifyListeners();
    } catch (e) {
      print(
          'VariantValueProvider: Failed to fetch variant values by option ID $optionId: $e');
      rethrow; // Allow caller to handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVariantValue(VariantValue item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.addVariantValue(item);
      await fetchVariantValues(); // Refresh the list after adding
      print('VariantValueProvider: Added variant value: $item');
    } catch (e) {
      print('VariantValueProvider: Failed to add variant value: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVariantValue(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteVariantValue(id);
      await fetchVariantValues(); // Refresh the list after deleting
      print('VariantValueProvider: Deleted variant value with ID: $id');
    } catch (e) {
      print(
          'VariantValueProvider: Failed to delete variant value with ID $id: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
