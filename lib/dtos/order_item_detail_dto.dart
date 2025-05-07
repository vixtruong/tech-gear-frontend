class OrderItemDetailDto {
  final int productItemId;
  final String productName;
  final String sku;
  final String imageUrl;
  final double price;
  final int discount;
  final int quantity;
  final int totalPrice;

  OrderItemDetailDto({
    required this.productItemId,
    required this.productName,
    required this.sku,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemDetailDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDetailDto(
      productItemId: json['productItemId'] as int,
      productName: json['productName'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discount: json['discount'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      totalPrice: json['totalPrice'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productItemId': productItemId,
      'productName': productName,
      'sku': sku,
      'imageUrl': imageUrl,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}
