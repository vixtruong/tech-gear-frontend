import 'package:flutter/material.dart';
import 'package:techgear/models/product_config.dart';
import 'package:techgear/services/product_services/product_config_service.dart';

class ProductConfigProvider with ChangeNotifier {
  final ProductConfigService _service = ProductConfigService();

  List<ProductConfig> _productConfigs = [];

  List<ProductConfig> get productConfigs => _productConfigs;

  Future<void> fetchProductConfigs() async {
    try {
      List<Map<String, dynamic>> fetchData =
          await _service.fetchProductConfigs();
      _productConfigs = fetchData
          .map((data) => ProductConfig.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchProductConfigsByProductItemId(String productItemId) async {
    try {
      List<Map<String, dynamic>> fetchData =
          await _service.fetchProductConfigsByProductItemId(productItemId);
      _productConfigs = fetchData
          .map((data) => ProductConfig.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> addProductConfig(ProductConfig config) async {
    await _service.addProductConfig(config);
    await fetchProductConfigs();
  }
}
