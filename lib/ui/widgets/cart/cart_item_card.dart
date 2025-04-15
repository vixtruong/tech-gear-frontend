import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/product_item_info_dto.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';

class CartItemCard extends StatefulWidget {
  final int productItemId;
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const CartItemCard({
    super.key,
    required this.productItemId,
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  ProductItemInfoDto? _productInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductInfo();
  }

  Future<void> _loadProductInfo() async {
    try {
      final productProvider =
          Provider.of<ProductItemProvider>(context, listen: false);
      final productInfo = await productProvider.fetchProductItemsByIds(
          [widget.productItemId]).then((list) => list?.first);
      if (mounted) {
        setState(() {
          _productInfo = productInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load product info: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vndFormat = NumberFormat.decimalPattern('vi_VN');
    final isWeb = MediaQuery.of(context).size.width >= 800;
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _productInfo?.imgUrl ?? 'https://via.placeholder.com/100',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _productInfo?.productName ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${_productInfo?.sku ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${vndFormat.format(_productInfo?.price ?? 0)}đ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          if (!isWeb) // Chỉ hiển thị trên mobile
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: widget.onDecrease,
                                ),
                                Text(
                                  '${widget.quantity}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: widget.onIncrease,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
