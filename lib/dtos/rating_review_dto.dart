class RatingReviewDto {
  final int id;
  final int productItemId;
  final String productName;
  final String sku;
  final String imgUrl;
  final int userId;
  final int orderId;
  final int star;
  final String? content;
  final DateTime lastUpdate;

  RatingReviewDto({
    required this.id,
    required this.productItemId,
    required this.productName,
    required this.sku,
    required this.imgUrl,
    required this.userId,
    required this.orderId,
    required this.star,
    this.content,
    required this.lastUpdate,
  });

  factory RatingReviewDto.fromJson(Map<String, dynamic> json) {
    return RatingReviewDto(
      id: json['id'] as int,
      productItemId: json['productItemId'] as int,
      productName: json['productName'] as String,
      sku: json['sku'] as String,
      imgUrl: json['imgUrl'] as String,
      userId: json['userId'] as int,
      orderId: json['orderId'] as int,
      star: json['star'] as int,
      content: json['content'] as String?,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productItemId': productItemId,
      'productName': productName,
      'sku': sku,
      'userId': userId,
      'orderId': orderId,
      'star': star,
      'content': content,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}
