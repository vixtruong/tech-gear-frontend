class OrderItemDto {
  final int? id;
  final int productItemId;
  final int quantity;
  final int price;

  OrderItemDto({
    this.id,
    required this.productItemId,
    required this.quantity,
    required this.price,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: json['id'],
      productItemId: json['productItemId'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productItemId': productItemId,
        'quantity': quantity,
        'price': price,
      };
}
