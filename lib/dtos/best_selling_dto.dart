class BestSellingDto {
  final String category;
  final int sellingQuantity;

  BestSellingDto({
    required this.category,
    required this.sellingQuantity,
  });

  factory BestSellingDto.fromJson(Map<String, dynamic> json) {
    return BestSellingDto(
      category: json['category'] ?? '',
      sellingQuantity: json['sellingQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'sellingQuantity': sellingQuantity,
    };
  }
}
