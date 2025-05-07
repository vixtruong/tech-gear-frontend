import 'package:flutter/material.dart';
import 'package:techgear/dtos/product_item_info_dto.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/product_services/product_item_service.dart';

class ProductItemProvider with ChangeNotifier {
  final ProductItemService _service;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  ProductItemProvider(this._sessionProvider)
      : _service = ProductItemService(_sessionProvider);
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

  Future<List<ProductItemInfoDto>?> fetchProductItemsByIds(
      List<int> productItemIds) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductItemsInfoByIds(productItemIds);
      var result =
          fetchedData.map((data) => ProductItemInfoDto.fromMap(data)).toList();

      return result;
    } catch (e) {
      e.toString();
      return null;
    }
  }

  Future<List<int>> getPrice(List<int> productItemIds) async {
    try {
      if (productItemIds.isEmpty) {
        return []; // Return empty list for empty input
      }

      List<int> priceData = await _service.getPrice(productItemIds);

      return priceData;
    } catch (e) {
      e.toString();
      return List.empty();
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

  Future<bool> setDiscount(int productItemId, int discount) async {
    try {
      final success = await _service.setDiscount(productItemId, discount);

      return success;
    } catch (e) {
      e.toString();
    }

    return false;
  }
}
