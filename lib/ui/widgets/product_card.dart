import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/data/models/product.dart';
import 'package:techgear/ui/widgets/star_rating.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool atHome;

  const ProductCard({super.key, required this.product, required this.atHome});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product-detail');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    'https://product.hstatic.net/200000722513/product/ava_dea980b662854ab8a4dd359d3bd8d2b4_medium.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                _buttonFavorite(widget.atHome),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${widget.product.colors} colors",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${widget.product.price}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 8.0),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => const CartScreen(),
                      //         ),
                      //       );
                      //     },
                      //     child: CircleAvatar(
                      //       backgroundColor: Colors.grey[200],
                      //       radius: 12,
                      //       child: Icon(
                      //         Icons.add_shopping_cart_outlined,
                      //         size: 20,
                      //         color: Colors.black,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Row(
                    children: [
                      StarRating(rating: widget.product.rating),
                      SizedBox(width: 5),
                      Text(
                        "1234",
                        style: TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonFavorite(bool atHome) {
    if (atHome) {
      return Positioned(
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
            backgroundColor: Colors.grey[400]!.withAlpha((0.5 * 255).toInt()),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red[300] : Colors.black54,
            ),
          ),
        ),
      );
    }
    return Text("");
  }
}
