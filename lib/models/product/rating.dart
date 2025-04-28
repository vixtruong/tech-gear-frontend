class Rating {
  final int? id;
  final int productItemId;
  final int userId;
  final int orderId;
  final int star;
  final String? content;
  final DateTime lastUpdate;

  Rating({
    this.id,
    required this.productItemId,
    required this.userId,
    required this.orderId,
    required this.star,
    this.content,
    required this.lastUpdate,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as int,
      productItemId: json['productItemId'] as int,
      userId: json['userId'] as int,
      orderId: json['orderId'] as int,
      star: json['star'] as int,
      content: json['content'] as String?,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'productItemId': productItemId,
      'userId': userId,
      'orderId': orderId,
      'star': star,
      'content': content,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
