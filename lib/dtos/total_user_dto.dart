class TotalUserDto {
  final int totalUsers;
  final int newUsers;

  TotalUserDto({
    required this.totalUsers,
    required this.newUsers,
  });

  factory TotalUserDto.fromJson(Map<String, dynamic> json) {
    return TotalUserDto(
      totalUsers: json['totalUsers'] as int? ?? 0,
      newUsers: json['newUsers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'newUsers': newUsers,
    };
  }
}
