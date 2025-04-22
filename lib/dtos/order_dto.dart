import 'package:techgear/dtos/order_item_dto.dart';

class OrderDto {
  final int? id;
  final int userId;
  final int userAddressId;
  final int? couponId;
  final int totalAmount;
  final String paymentMethod;
  final String? note;
  final bool isUsePoint;
  final DateTime createdAt;
  final List<OrderItemDto>? orderItems;

  OrderDto({
    this.id,
    required this.userId,
    required this.userAddressId,
    this.couponId,
    required this.totalAmount,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.isUsePoint,
    this.orderItems,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'],
      userId: json['userId'],
      userAddressId: json['userAddressId'],
      couponId: json['couponId'],
      totalAmount: json['totalAmount'],
      paymentMethod: json['paymentMethod'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      isUsePoint: json['isUsePoint'],
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((item) => OrderItemDto.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userAddressId': userAddressId,
        'couponId': couponId,
        'isUsePoint': isUsePoint,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'orderItems': orderItems?.map((item) => item.toJson()).toList(),
      };
}
