class LoyaltyDto {
  final int id;
  final int userId;
  final int? fromOrderId; // Có thể null nếu không liên quan đến đơn hàng
  final int point;
  final String action; // 'get' hoặc 'use'
  final DateTime createdAt;

  LoyaltyDto({
    required this.id,
    required this.userId,
    this.fromOrderId,
    required this.point,
    required this.action,
    required this.createdAt,
  });

  factory LoyaltyDto.fromJson(Map<String, dynamic> json) {
    return LoyaltyDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      fromOrderId: json['fromOrderId'] as int?, // Có thể null
      point: json['point'] as int,
      action: json['action'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fromOrderId': fromOrderId,
      'point': point,
      'action': action,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
