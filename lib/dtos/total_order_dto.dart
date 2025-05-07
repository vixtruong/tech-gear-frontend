class TotalOrderDto {
  final int totalOrders;
  final int totalRevenue;

  TotalOrderDto({
    required this.totalOrders,
    required this.totalRevenue,
  });

  factory TotalOrderDto.fromJson(Map<String, dynamic> json) {
    return TotalOrderDto(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: json['totalRevenue'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
    };
  }
}
