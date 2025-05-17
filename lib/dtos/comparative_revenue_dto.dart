class ComparativeRevenueDto {
  final List<PeriodRevenue> currentPeriod;
  final List<PeriodRevenue> previousPeriod;

  ComparativeRevenueDto({
    required this.currentPeriod,
    required this.previousPeriod,
  });

  factory ComparativeRevenueDto.fromJson(Map<String, dynamic> json) {
    return ComparativeRevenueDto(
      currentPeriod: (json['currentPeriod'] as List)
          .map((item) => PeriodRevenue.fromJson(item))
          .toList(),
      previousPeriod: (json['previousPeriod'] as List)
          .map((item) => PeriodRevenue.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPeriod': currentPeriod.map((item) => item.toJson()).toList(),
      'previousPeriod': previousPeriod.map((item) => item.toJson()).toList(),
    };
  }
}

class PeriodRevenue {
  final String periodName;
  final double revenue;

  PeriodRevenue({
    required this.periodName,
    required this.revenue,
  });

  factory PeriodRevenue.fromJson(Map<String, dynamic> json) {
    return PeriodRevenue(
      periodName: json['periodName'] ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodName': periodName,
      'revenue': revenue,
    };
  }
}
