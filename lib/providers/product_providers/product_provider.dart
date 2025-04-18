import 'package:flutter/foundation.dart';

import '../../models/product/product.dart';
import '../../services/product_services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    try {
      List<Map<String, dynamic>> fetchedData = await _service.fetchProducts();
      _products = fetchedData.map((data) => Product.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<Product?> fetchProductById(String productId) async {
    final productData = await _service.fetchProductById(productId);
    return productData != null ? Product.fromMap(productData) : null;
  }

  Future<void> addProduct(Product product) async {
    await _service.addProduct(product);
    await fetchProducts();
  }
}
