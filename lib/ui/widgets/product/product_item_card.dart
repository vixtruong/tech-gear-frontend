import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/ui/screens/dashboard/pages/manage_coupons_screen.dart';

class ProductItemCard extends StatefulWidget {
  final ProductItem productItem;

  const ProductItemCard({super.key, required this.productItem});

  @override
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  // Controller for the discount input field
  final TextEditingController _discountController = TextEditingController();

  // Show dialog to set discount
  Future<void> _showSetDiscountDialog(BuildContext context) async {
    _discountController.text = widget.productItem.discount.toString();
    final outerContext = context;

    return showDialog(
      context: outerContext,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Set Discount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _discountController,
                      hint: "Discount",
                      inputType: TextInputType.number,
                      isSearch: false),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                        onPressed: () {
                          Navigator.of(outerContext).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final newDiscount =
                              int.tryParse(_discountController.text);
                          if (newDiscount != null &&
                              newDiscount >= 0 &&
                              newDiscount <= 100) {
                            try {
                              final productProvider =
                                  Provider.of<ProductItemProvider>(context,
                                      listen: false);
                              await productProvider.setDiscount(
                                int.parse(widget.productItem.id!),
                                newDiscount,
                              );
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Discount updated successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(outerContext).pop();
                            }
                          } else {
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter a valid discount (0-100)'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            widget.productItem.imgUrl,
            height: 100,
            width: 100,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productItem.sku,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Text(
                  "8GB 256GB BLACK",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text("Stock ${widget.productItem.quantity}"),
                Text(
                  NumberFormat("#,###", "vi_VN")
                      .format(widget.productItem.price),
                ),
                Text("Discount ${widget.productItem.discount}%"),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'edit') {
                // Handle edit action (e.g., navigate to edit screen)
              } else if (value == 'set_discount') {
                _showSetDiscountDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'set_discount',
                child: Text('Set Discount'),
              ),
            ],
            icon: const Icon(Icons.more_vert_outlined),
          ),
        ],
      ),
    );
  }
}
