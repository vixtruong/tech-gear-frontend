import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/models/product/variant_value.dart';

class ColorVariantBox extends StatelessWidget {
  final VariantValue color;
  final ProductItem selectedProductItem;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorVariantBox({
    super.key,
    required this.color,
    required this.selectedProductItem,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate discounted price if discount > 0
    final bool hasDiscount = selectedProductItem.discount > 0;
    final double discountedPrice = hasDiscount
        ? selectedProductItem.price * (1 - selectedProductItem.discount / 100)
        : selectedProductItem.price;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: isSelected ? Colors.red : Colors.black26,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  color.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (hasDiscount) ...[
                  // Original price (strikethrough)
                  Text(
                    "${NumberFormat("#,###", "vi_VN").format(selectedProductItem.price)} đ",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  // Discounted price
                  Text(
                    "${NumberFormat("#,###", "vi_VN").format(discountedPrice)} đ",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  // Price without discount
                  Text(
                    "${NumberFormat("#,###", "vi_VN").format(selectedProductItem.price)} đ",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          // Discount badge (optional, for extra prominence)
          if (hasDiscount)
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "-${selectedProductItem.discount}%",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
