class ProductItemInfoDto {
  int productItemId;
  String productName;
  String sku;
  String imgUrl;
  double price;
  int discount;

  ProductItemInfoDto({
    required this.productItemId,
    required this.productName,
    required this.sku,
    required this.imgUrl,
    required this.price,
    required this.discount,
  });

  factory ProductItemInfoDto.fromMap(Map<String, dynamic> data) {
    return ProductItemInfoDto(
      productItemId: data['productItemId'] as int? ?? -1,
      productName: data['productName'] as String? ?? 'Tên không xác định',
      sku: data['sku'] as String? ?? 'SKU không xác định',
      imgUrl: data['imageUrl'] as String? ?? '',
      price: (data['price'] is double)
          ? data['price'] as double
          : double.tryParse(data['price']?.toString() ?? '0.0') ??
              0.0, // Đã an toàn
      discount: data['discount'] as int,
    );
  }
}
