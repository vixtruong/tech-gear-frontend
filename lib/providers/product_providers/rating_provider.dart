import 'package:flutter/material.dart';
import 'package:techgear/dtos/average_rating_dto.dart';
import 'package:techgear/services/product_services/rating_service.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();

  Future<AverageRatingDto?> fetchProductAvarageRating(int productId) async {
    final data = await _ratingService.fetchProductAvarageRating(productId);

    return data != null ? AverageRatingDto.fromMap(data) : null;
  }
}
