import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techgear/models/product_item.dart';
import 'package:techgear/models/variant_value.dart';

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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${NumberFormat("#,###", "vi_VN").format(selectedProductItem.price)} đ",
                  style: const TextStyle(fontSize: 12),
                ),
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
        ],
      ),
    );
  }
}
