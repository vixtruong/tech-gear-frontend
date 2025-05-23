import 'package:techgear/dtos/order_item_dto.dart';

class OrderDto {
  final int? id;
  final int userId;
  final int userAddressId;
  final int? couponId;
  final int totalAmount;
  final int? paymentAmount;
  final String paymentMethod;
  final String? note;
  final String? status;
  final bool isUsePoint;
  final DateTime createdAt;
  final DateTime? deliveredDate;
  final DateTime? confirmedDate;
  final DateTime? shippedDate;
  final DateTime? canceledDate;
  final String? cancelReason;
  final List<OrderItemDto>? orderItems;

  OrderDto({
    this.id,
    required this.userId,
    required this.userAddressId,
    this.couponId,
    required this.totalAmount,
    this.paymentAmount,
    required this.paymentMethod,
    this.note,
    this.status,
    required this.createdAt,
    this.deliveredDate,
    this.confirmedDate,
    this.shippedDate,
    this.canceledDate,
    this.cancelReason,
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
      paymentAmount: json['paymentAmount'],
      paymentMethod: json['paymentMethod'] ?? '',
      note: json['note'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
      confirmedDate: json['confirmedDate'] != null
          ? DateTime.parse(json['confirmedDate'])
          : null,
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'])
          : null,
      canceledDate: json['canceledDate'] != null
          ? DateTime.parse(json['canceledDate'])
          : null,
      cancelReason: json['cancelReason'] ?? '',
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
        'paymentAmount': paymentAmount,
        'paymentMethod': paymentMethod,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'orderItems': orderItems?.map((item) => item.toJson()).toList(),
      };
}
