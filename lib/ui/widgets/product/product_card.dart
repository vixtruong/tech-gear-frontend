import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:techgear/models/product/product.dart';
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
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
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
              blurRadius: kIsWeb ? 8 : 6,
              offset: Offset(0, kIsWeb ? 4 : 2),
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
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(
                        Icons.broken_image,
                        size: kIsWeb ? 100 : 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                _buttonFavorite(widget.atHome),
                _buttonAddToCart(widget.atHome),
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
                      StarRating(rating: 4.5),
                      const SizedBox(width: 6),
                      Text(
                        "1234",
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
        left: 8,
        child: GestureDetector(
          onTap: () {
            setState(() {
              isFavorite = !isFavorite;
              // TODO: Sync with WishlistProvider
            });
          },
          child: CircleAvatar(
            radius: 20,
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

  Widget _buttonAddToCart(bool visible) {
    return Visibility(
      visible: visible,
      child: Positioned(
        top: 8,
        right: 8,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.withOpacity(0.4),
          child: IconButton(
            onPressed: () {
              // TODO: Add to CartProvider
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${widget.product.name} added to cart"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            iconSize: 20,
            icon: const Icon(
              Icons.add_shopping_cart_outlined,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
