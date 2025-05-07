class OrderStatusDto {
  final int orderId;
  final String status;
  String? cancelReason;

  OrderStatusDto({
    required this.orderId,
    required this.status,
    this.cancelReason,
  });

  void setCancelReason(String reason) {
    cancelReason = reason;
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'status': status,
        'cancelReason': cancelReason ?? '',
      };
}
