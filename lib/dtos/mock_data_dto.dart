class MockDataDto {
  final int totalOrders;
  final double revenue;
  final double growth;
  final double growthPercent;

  MockDataDto({
    required this.totalOrders,
    required this.revenue,
    required this.growth,
    required this.growthPercent,
  });

  factory MockDataDto.fromJson(Map<String, dynamic> json) {
    return MockDataDto(
      totalOrders: json['totalOrders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      growth: (json['growth'] ?? 0).toDouble(),
      growthPercent: (json['growthPercent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'revenue': revenue,
      'growth': growth,
      'growthPercent': growthPercent,
    };
  }
}
