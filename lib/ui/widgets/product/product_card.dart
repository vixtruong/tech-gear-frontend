import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/average_rating_dto.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/providers/product_providers/rating_provider.dart';
// import 'package:techgear/services/cart_service/cart_service.dart';
import 'package:techgear/ui/widgets/review/star_rating.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool atHome;

  const ProductCard({
    super.key,
    required this.product,
    this.atHome = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late RatingProvider _ratingProvider;

  AverageRatingDto? averageRating;
  bool isFavorite = false;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    _loadInformations();
  }

  Future<void> _loadInformations() async {
    try {
      final result = await _ratingProvider
          .fetchProductAvarageRating(int.parse(widget.product.id));

      setState(() {
        averageRating = result;
        _isLoading = false;
      });
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          context.go(
              '/product-detail?productId=${widget.product.id}&isAdmin=false');
        } else {
          context.push(
              '/product-detail?productId=${widget.product.id}&isAdmin=false');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imgUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          size: double.infinity,
                          color: Colors.grey,
                        ),
                        memCacheWidth: 300, // Giới hạn chiều rộng bộ đệm
                        memCacheHeight: 300, // Giới hạn chiều cao bộ đệm
                        fadeInDuration: const Duration(
                            milliseconds: 200), // Giảm thời gian hiệu ứng
                      )),
                ),
                _buttonFavorite(widget.atHome),
                // _buttonAddToCart(
                //     widget.atHome, () => _addToCart(widget.product.id)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${NumberFormat("#,###", "vi_VN").format(widget.product.price)} đ",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(rating: averageRating!.averageRating),
                      const SizedBox(width: 6),
                      Text(
                        '${averageRating?.ratingCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonFavorite(bool visible) {
    return Visibility(
      visible: visible,
      child: Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
          child: CircleAvatar(
            radius: 20,
            // ignore: deprecated_member_use
            backgroundColor: Colors.grey.withOpacity(0.4),
            child: Icon(
              size: 20,
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red[300] : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buttonAddToCart(bool visible, VoidCallback onPressed) {
  //   return Visibility(
  //     visible: visible,
  //     child: Positioned(
  //       top: 8,
  //       right: 8,
  //       child: CircleAvatar(
  //         radius: 20,
  //         // ignore: deprecated_member_use
  //         backgroundColor: Colors.grey.withOpacity(0.4),
  //         child: IconButton(
  //           onPressed: onPressed,
  //           iconSize: 20,
  //           icon: const Icon(
  //             Icons.add_shopping_cart_outlined,
  //             color: Colors.black54,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
