import 'dart:io';

class ProductItem {
  String? id;
  String sku;
  File imgFile;
  String imgUrl;
  int quantity;
  double price;
  String productId;
  DateTime? createdAt;
  bool available;
  int discount;

  ProductItem({
    this.id,
    required this.sku,
    required this.imgFile,
    this.imgUrl = "",
    required this.quantity,
    required this.price,
    required this.productId,
    this.createdAt,
    this.available = true,
    this.discount = 0,
  });

  factory ProductItem.fromMap(Map<String, dynamic> data) {
    return ProductItem(
      id: data['id']?.toString() ?? '',
      sku: data['sku'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imgFile: File(''),
      imgUrl: data['productImage'] ?? '',
      productId: data['productId']?.toString() ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
      available: data['available'] == true,
      discount: data['discount'] ?? 0,
    );
  }
}
