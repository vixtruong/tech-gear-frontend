import 'package:flutter/material.dart';
import 'package:techgear/models/product_item.dart';
import 'package:techgear/services/product_services/product_item_service.dart';

class ProductItemProvider with ChangeNotifier {
  final ProductItemService _service = ProductItemService();
  List<ProductItem> _productItems = [];

  List<ProductItem> get productItems => _productItems;

  Future<void> fetchProductItems() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductItems();
      _productItems =
          fetchedData.map((data) => ProductItem.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchProductItemsByProductId(String productId) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductItemsByProductId(productId);
      _productItems =
          fetchedData.map((data) => ProductItem.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<ProductItem?> addProductItem(ProductItem productItem) async {
    try {
      final result = await _service.addProductItem(productItem);
      if (result != null) {
        final addedItem = ProductItem.fromMap(result);
        _productItems.add(addedItem);
        notifyListeners();
        return addedItem;
      }
    } catch (e) {
      e.toString();
    }
    return null;
  }
}
