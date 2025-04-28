import 'package:image_picker/image_picker.dart';

class ProductItem {
  String? id;
  String sku;
  XFile imgFile;
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
      imgFile: XFile(''),
      imgUrl: data['productImage'] ?? '',
      productId: data['productId']?.toString() ?? '',
      quantity: (data['qtyInStock'] ?? 0).toInt(),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
      available: data['available'] == true,
      discount: data['discount'] ?? 0,
    );
  }
}
