class PaymentDto {
  final int id;
  final int orderId;
  final int amount;
  final String? method;
  final DateTime? paidAt;

  PaymentDto({
    required this.id,
    required this.orderId,
    required this.amount,
    this.method,
    this.paidAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      amount: json['amount'] as int,
      method: json['method'] as String?,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'method': method,
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}
