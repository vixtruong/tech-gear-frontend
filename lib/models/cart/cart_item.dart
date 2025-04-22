class CartItem {
  final String productItemId;
  final int quantity;
  final int? price;

  const CartItem(
      {required this.productItemId, required this.quantity, this.price = 0});

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      productItemId: data['productItemId']?.toString() ?? '',
      quantity: int.tryParse(data['quantity'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productItemId': productItemId,
      'quantity': quantity,
    };
  }

  CartItem copyWith({String? productItemId, int? quantity}) {
    return CartItem(
      productItemId: productItemId ?? this.productItemId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          productItemId == other.productItemId &&
          quantity == other.quantity;

  @override
  int get hashCode => productItemId.hashCode ^ quantity.hashCode;
}
