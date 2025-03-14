import 'package:flutter/material.dart';
import 'package:techgear/models/product_item.dart';
import 'package:techgear/services/product_item_service.dart';

class ProductItemProvider with ChangeNotifier {
  final ProductItemService _service = ProductItemService();
  List<ProductItem> _productItems = [];

  List<ProductItem> get productItems => _productItems;

  Future<void> fetchProductItems() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductItems();
      _productItems = fetchedData
          .map((data) => ProductItem.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> fetchProductItemsByProductId(String productId) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductItemsByProductId(productId);
      _productItems = fetchedData
          .map((data) => ProductItem.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {}
  }

  Future<ProductItem?> fetchProductById(String productItemId) async {
    final productData = await _service.fetchProductItemById(productItemId);
    return productData != null
        ? ProductItem.fromMap(productData, productItemId)
        : null;
  }

  Future<void> addProduct(ProductItem productItem) async {
    await _service.addProductItem(productItem);
    await fetchProductItems();
  }

  @override
  void notifyListeners() {}
}
