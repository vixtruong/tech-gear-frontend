import 'package:cloud_firestore/cloud_firestore.dart';

class ProductConfig {
  String id;
  String productItemId;
  String variantValueId;

  ProductConfig({
    this.id = "",
    required this.productItemId,
    required this.variantValueId,
  });

  factory ProductConfig.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductConfig(
      id: documentId,
      productItemId: (data['product_item'] as DocumentReference).id,
      variantValueId: (data['variant_value'] as DocumentReference).id,
    );
  }
}
