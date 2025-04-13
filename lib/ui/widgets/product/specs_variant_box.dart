import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techgear/models/product/group_product_specs.dart';
import 'package:techgear/models/product/product_item.dart';

class SpecsVariantBox extends StatelessWidget {
  final GroupProductSpecs specs;
  final bool isSelect;
  final VoidCallback onTap;

  const SpecsVariantBox({
    super.key,
    required this.specs,
    required this.isSelect,
    required this.onTap,
  });

  String _getMinPrice(List<ProductItem> items) {
    if (items.isEmpty) return "N/A";

    double minPrice =
        items.map((item) => item.price).reduce((a, b) => a < b ? a : b);

    return "${NumberFormat("#,###", "vi_VN").format(minPrice)} đ";
  }

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
                color: isSelect ? Colors.red : Colors.black26,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var value in specs.specs)
                  Text(
                    value.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  _getMinPrice(specs.productItems),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSelect)
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
