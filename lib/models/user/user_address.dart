class UserAddress {
  final int? id;
  final int userId;
  final String address;
  final String recipientName;
  final String recipientPhone;
  final bool isDefault;
  final DateTime createdAt;

  UserAddress({
    this.id,
    required this.userId,
    required this.address,
    required this.recipientName,
    required this.recipientPhone,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory constructor: map từ JSON ra object
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      address: json['address'] as String,
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert object ngược lại thành JSON để gửi lên server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'address': address,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
