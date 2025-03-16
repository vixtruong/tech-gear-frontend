import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final File imgFile;
  final String imgUrl;
  final String brandId;
  final String categoryId;
  final bool isDisabled;
  const Product({
    required this.name,
    this.id = "",
    required this.price,
    required this.description,
    required this.brandId,
    required this.categoryId,
    required this.imgFile,
    required this.imgUrl,
    this.isDisabled = false,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imgFile: File(""),
      imgUrl: data['imageUrl'] ?? '',
      brandId: (data['brand'] as DocumentReference).id,
      categoryId: (data['category'] as DocumentReference).id,
      isDisabled: data['isDisabled'] ?? false,
    );
  }
}
