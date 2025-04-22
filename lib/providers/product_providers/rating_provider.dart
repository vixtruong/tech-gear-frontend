import 'package:flutter/material.dart';
import 'package:techgear/dtos/average_rating_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/product_services/rating_service.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _service;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  RatingProvider(this._sessionProvider)
      : _service = RatingService(_sessionProvider);

  Future<AverageRatingDto?> fetchProductAvarageRating(int productId) async {
    final data = await _service.fetchProductAvarageRating(productId);

    return data != null ? AverageRatingDto.fromMap(data) : null;
  }
}
