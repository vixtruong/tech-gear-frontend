import 'package:cloud_firestore/cloud_firestore.dart';

class VariantValue {
  String id;
  String name;
  String variantOptionId;

  VariantValue({
    this.id = "",
    required this.name,
    required this.variantOptionId,
  });

  factory VariantValue.fromMap(Map<String, dynamic> data, String documentId) {
    return VariantValue(
      id: documentId,
      name: data['name'] ?? '',
      variantOptionId: (data['variant_option'] as DocumentReference).id,
    );
  }
}
