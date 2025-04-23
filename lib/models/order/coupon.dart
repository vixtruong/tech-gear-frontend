class Coupon {
  final int id;
  final String code;
  final int value;
  final int usageLimit;
  final DateTime? expirationDate;
  final int minimumOrderAmount;

  Coupon({
    required this.id,
    required this.code,
    required this.value,
    required this.usageLimit,
    this.expirationDate,
    required this.minimumOrderAmount,
  });

  // ✅ FROM JSON
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      value: json['value'],
      usageLimit: json['usageLimit'],
      expirationDate: DateTime.parse(json['expirationDate']),
      minimumOrderAmount: json['minimumOrderAmount'],
    );
  }

  // ✅ TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'value': value,
      'usageLimit': usageLimit,
      'expirationDate': expirationDate!.toIso8601String(),
      'minimumOrderAmount': minimumOrderAmount,
    };
  }
}
