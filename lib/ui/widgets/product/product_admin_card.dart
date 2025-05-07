import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';

class ProductAdminCard extends StatefulWidget {
  final Product product;

  const ProductAdminCard({super.key, required this.product});

  @override
  State<ProductAdminCard> createState() => _ProductAdminCardState();
}

class _ProductAdminCardState extends State<ProductAdminCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(8.0),
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
      child: InkWell(
        onTap: () {
          context.pushReplacement(
              '/product-detail?productId=${widget.product.id}&isAdmin=true');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(
              widget.product.imgUrl,
              height: 100,
              width: 100,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widget.product.name,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widget.product.description,
                  ),
                  Text(
                    NumberFormat("#,###", "vi_VN").format(widget.product.price),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                // Xử lý khi chọn một mục
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                  onTap: () {
                    if (kIsWeb) {
                      context.pushReplacement(
                          '/edit-product/${widget.product.id}');
                    } else {
                      context.push('/edit-product/${widget.product.id}');
                    }
                  },
                ),
                PopupMenuItem(
                  value: (widget.product.available) ? 'Disable' : "Enable",
                  child: (widget.product.available)
                      ? Text('Disable')
                      : Text('Enable'),
                  onTap: () async {
                    final productProvider =
                        Provider.of<ProductProvider>(context, listen: false);

                    await productProvider
                        .toggleProductStatus(int.parse(widget.product.id));
                  },
                ),
                PopupMenuItem(
                  onTap: () {
                    context.pushReplacement(
                        '/manage-product-variants/${widget.product.id}');
                  },
                  value: 'variants',
                  child: Text('Manage variants'),
                ),
              ],
              icon: Icon(Icons.more_vert_outlined),
            )
          ],
        ),
      ),
    );
  }
}
