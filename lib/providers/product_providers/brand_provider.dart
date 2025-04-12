import 'package:flutter/material.dart';
import 'package:techgear/models/brand.dart';
import 'package:techgear/services/product_services/brand_service.dart';

class BrandProvider with ChangeNotifier {
  final BrandService _service = BrandService();

  List<Brand> _brands = [];

  List<Brand> get brands => _brands;

  Future<void> fetchBrands() async {
    try {
      List<Map<String, dynamic>> fetchedData = await _service.fetchBrands();
      _brands = fetchedData.map((data) => Brand.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      e.toString();
    }
    notifyListeners();
  }

  Future<Brand?> fetchBrandById(String brandId) async {
    final brandData = await _service.fetchBrandById(brandId);
    return brandData != null ? Brand.fromMap(brandData) : null;
  }

  Future<Brand?> fetchBrandByName(String brandName) async {
    final brandData = await _service.fetchBrandByName(brandName);
    return brandData != null ? Brand.fromMap(brandData) : null;
  }

  Future<void> addBrand(String brand) async {
    await _service.addBrand(brand);
    await fetchBrands();
  }
}
