import 'package:image_picker/image_picker.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final XFile imgFile;
  final String imgUrl;
  final String brandId;
  final String categoryId;
  final bool available;

  const Product({
    required this.name,
    this.id = "",
    required this.price,
    required this.description,
    required this.brandId,
    required this.categoryId,
    required this.imgFile,
    required this.imgUrl,
    this.available = true,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imgFile: XFile(''),
      imgUrl: data['productImage'] ?? '',
      brandId: data['brandId']?.toString() ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
      available: data['available'] ?? true,
    );
  }
}
