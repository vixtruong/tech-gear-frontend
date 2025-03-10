import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    try {
      List<Map<String, dynamic>> fetchedData = await _service.fetchProducts();
      _products = fetchedData
          .map((data) => Product.fromMap(data, data['id'] as String))
          .toList();
      notifyListeners();
    } catch (e) {}
  }

  Future<Product?> fetchProductById(String productId) async {
    final productData = await _service.fetchProductById(productId);
    return productData != null ? Product.fromMap(productData, productId) : null;
  }

  Future<void> addProduct(Product product) async {
    await _service.addProduct(product);
    await fetchProducts();
  }

  @override
  void notifyListeners() {}
}
