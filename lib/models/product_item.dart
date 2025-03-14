import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItem {
  String id;
  String SKU;
  File imgFile;
  String imgUrl;
  int quantity;
  double price;
  String productId;
  Timestamp? createdAt;

  ProductItem({
    required this.id,
    required this.SKU,
    required this.imgFile,
    this.imgUrl = "",
    required this.quantity,
    required this.price,
    required this.productId,
    this.createdAt,
  });

  factory ProductItem.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductItem(
      id: documentId,
      SKU: data['SKU'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imgFile: File(""),
      imgUrl: data['imageUrl'] ?? '',
      productId: (data['product'] as DocumentReference).id,
      quantity: (data['quantity'] ?? 0).toInt(),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
