import 'package:techgear/dtos/order_item_detail_dto.dart';

class OrderDetailDto {
  final int orderId;
  final String userEmail;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final int? point;
  final String? couponCode;
  final double orderTotalPrice;
  final double paymentTotalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final List<OrderItemDetailDto> orderItems;

  OrderDetailDto({
    required this.orderId,
    required this.userEmail,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    this.point,
    this.couponCode,
    required this.orderTotalPrice,
    required this.paymentTotalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.orderItems,
  });

  factory OrderDetailDto.fromJson(Map<String, dynamic> json) {
    return OrderDetailDto(
      orderId: json['orderId'] as int,
      userEmail: json['userEmail'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      point: json['point'] as int?,
      couponCode: json['couponCode'] as String?,
      orderTotalPrice: (json['orderTotalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentTotalPrice: (json['paymentTotalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime(2000),
      orderItems: (json['orderItems'] as List<dynamic>? ?? [])
          .map((item) => OrderItemDetailDto.fromJson(item))
          .toList(),
    );
  }
}
