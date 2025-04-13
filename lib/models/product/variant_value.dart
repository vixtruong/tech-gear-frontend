class VariantValue {
  String id;
  String name;
  String variantOptionId;

  VariantValue({
    this.id = "",
    required this.name,
    required this.variantOptionId,
  });

  factory VariantValue.fromMap(Map<String, dynamic> data) {
    return VariantValue(
      id: data['id']?.toString() ?? '',
      name: data['value'] ?? '',
      variantOptionId: data['variationId']?.toString() ?? '',
    );
  }
}
