class ProductConfig {
  String? id;
  String productItemId;
  String variantValueId;

  ProductConfig({
    this.id = "",
    required this.productItemId,
    required this.variantValueId,
  });

  factory ProductConfig.fromMap(Map<String, dynamic> data) {
    return ProductConfig(
      id: data['id']?.toString() ?? '',
      productItemId: data['productItemId']?.toString() ?? '',
      variantValueId: data['variationOptionId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productItemId': int.parse(productItemId),
      'variationOptionId': int.parse(variantValueId),
    };
  }
}
