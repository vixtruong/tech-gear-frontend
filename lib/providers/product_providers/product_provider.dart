import 'package:flutter/material.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';

import '../../models/product/product.dart';
import '../../services/product_services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  ProductProvider(this._sessionProvider)
      : _service = ProductService(_sessionProvider);
  List<Product> _products = [];
  List<Product> _newProducts = [];
  List<Product> _bestSellerProducts = [];
  List<Product> _promotionProducts = [];
  List<Product> _productByIds = [];

  List<Product> get products => _products;
  List<Product> get newProducts => _newProducts;
  List<Product> get bestSellerProducts => _bestSellerProducts;
  List<Product> get promotionProducts => _promotionProducts;
  List<Product> get productByIds => _productByIds;

  Future<void> fetchProductsForAdmin() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductsForAdmin();
      _products = fetchedData.map((data) => Product.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchProducts() async {
    try {
      List<Map<String, dynamic>> fetchedData = await _service.fetchProducts();
      _products = fetchedData.map((data) => Product.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchNewProducts() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchNewProducts();
      _newProducts = fetchedData.map((data) => Product.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchBestSellerProducts() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchBestSellerProducts();
      _bestSellerProducts =
          fetchedData.map((data) => Product.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchPromotionProducts() async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchPromotionProducts();
      _promotionProducts =
          fetchedData.map((data) => Product.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> fetchProductsByIds(List<int> ids) async {
    try {
      List<Map<String, dynamic>> fetchedData =
          await _service.fetchProductsByIds(ids);
      _productByIds = fetchedData.map((data) => Product.fromMap(data)).toList();
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

  Future<void> updateProduct(Product product) async {
    await _service.updateProduct(product);
    await fetchProducts();
  }

  Future<bool> toggleProductStatus(int productId) async {
    final success = await _service.toggleProductStatus(productId);
    await fetchProducts();

    return success;
  }
}
