import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import 'package:techgear/dtos/product_item_info_dto.dart';
import 'package:techgear/models/product/rating.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/providers/product_providers/rating_provider.dart';

class ProductRatingItem extends StatefulWidget {
  final ProductItemInfoDto item;
  final int orderId;

  const ProductRatingItem({
    super.key,
    required this.item,
    required this.orderId,
  });

  @override
  State<ProductRatingItem> createState() => _ProductRatingItemState();
}

class _ProductRatingItemState extends State<ProductRatingItem> {
  late SessionProvider _sessionProvider;
  late RatingProvider _ratingProvider;
  late OrderProvider _orderProvider;

  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRated = false;
  bool _isValidRating = true;
  bool _isLoading = true; // ✅ Thêm trạng thái loading

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _checkRated();
  }

  Future<void> _checkRated() async {
    try {
      final isRated = await _ratingProvider.checkIsRated(
        widget.orderId,
        widget.item.productItemId,
      );
      final isValidRating =
          await _orderProvider.checkValidRating(widget.orderId);
      if (mounted) {
        setState(() {
          _isRated = isRated;
          _isValidRating = isValidRating;
          _isLoading = false; // ✅ Dừng loading
        });
      }
    } catch (e) {
      debugPrint('Error checking rating status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;
      final content = _reviewController.text.trim();

      final rating = Rating(
        productItemId: widget.item.productItemId,
        userId: int.parse(userId!),
        orderId: widget.orderId,
        content: content,
        star: _rating.toInt(),
        lastUpdate: DateTime.now(),
      );

      await _ratingProvider.addRating(rating);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isRated = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (context.mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Center(
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(vertical: 32),
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: (_isLoading)
          ? Center(
              child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const SizedBox(height: 20),
                if (!_isRated && _isValidRating) ...[
                  _buildSectionTitle('Your rating'),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 32,
                    unratedColor: Colors.grey.shade300,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.orange),
                    onRatingUpdate: (rating) =>
                        setState(() => _rating = rating),
                  ),
                  if (_rating > 0) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('Your review'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Submit Rating',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ] else if (_isRated) ...[
                  Text(
                    'You have already rated this product.',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (!_isValidRating) ...[
                  Text(
                    'The rating period for this product has expired.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.item.imgUrl.isNotEmpty
              ? Image.network(
                  widget.item.imgUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _placeholderImage(),
                )
              : _placeholderImage(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.productName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'SKU: ${widget.item.sku}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }
}
