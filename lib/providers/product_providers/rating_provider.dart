import 'package:flutter/material.dart';
import 'package:techgear/dtos/average_rating_dto.dart';
import 'package:techgear/dtos/rating_review_dto.dart';
import 'package:techgear/models/product/rating.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/product_services/rating_service.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _service;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  List<RatingReviewDto> _ratings = [];
  List<RatingReviewDto> get ratings => _ratings;

  RatingProvider(this._sessionProvider)
      : _service = RatingService(_sessionProvider);

  Future<void> fetchRatingsByProductId(int productId) async {
    try {
      var fetchedData = await _service.fetchRatingsByProductId(productId);
      _ratings =
          fetchedData.map((data) => RatingReviewDto.fromJson(data)).toList();
    } catch (e) {
      e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchRatingsByUserId(int userId) async {
    try {
      var fetchedData = await _service.fetchRatingsByUserId(userId);
      _ratings =
          fetchedData.map((data) => RatingReviewDto.fromJson(data)).toList();
    } catch (e) {
      e.toString();
    }
    notifyListeners();
  }

  Future<AverageRatingDto?> fetchProductAvarageRating(int productId) async {
    final data = await _service.fetchProductAvarageRating(productId);

    return data != null ? AverageRatingDto.fromMap(data) : null;
  }

  Future<bool> checkIsRated(int orderId, int productItemId) async {
    try {
      return await _service.isRated(orderId, productItemId);
    } catch (e) {
      debugPrint('Error checking isRated: $e');
      return false;
    }
  }

  Future<void> addRating(Rating rating) async {
    try {
      await _service.addRating(rating);
    } catch (e) {
      e.toString();
    }
  }
}
