class VariantOption {
  String id;
  String name;
  String categoryId;

  VariantOption({
    this.id = "",
    required this.name,
    required this.categoryId,
  });

  factory VariantOption.fromMap(Map<String, dynamic> data) {
    return VariantOption(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
    );
  }
}
