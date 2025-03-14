import 'package:cloud_firestore/cloud_firestore.dart';

class VariantOption {
  String id;
  String name;
  String categoryId;

  VariantOption({
    this.id = "",
    required this.name,
    required this.categoryId,
  });

  factory VariantOption.fromMap(Map<String, dynamic> data, String documentId) {
    return VariantOption(
      id: documentId,
      name: data['name'] ?? '',
      categoryId: (data['category'] as DocumentReference).id,
    );
  }
}
