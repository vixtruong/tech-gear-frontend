class AverageRatingDto {
  int productId;
  double averageRating;
  int ratingCount;

  AverageRatingDto({
    required this.productId,
    this.averageRating = 0,
    this.ratingCount = 0,
  });

  factory AverageRatingDto.fromMap(Map<String, dynamic> data) {
    return AverageRatingDto(
      productId: data['productId'],
      averageRating: (data['averageRating'] as num).toDouble(),
      ratingCount: data['ratingCount'],
    );
  }
}
