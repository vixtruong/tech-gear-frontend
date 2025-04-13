import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techgear/models/product/product_item.dart';

class ProductItemCard extends StatefulWidget {
  final ProductItem productItem;

  const ProductItemCard({super.key, required this.productItem});

  @override
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            widget.productItem.imgUrl,
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
                  widget.productItem.sku,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  "8GB 256GB BLACK",
                ),
                Text("Stock ${widget.productItem.quantity}"),
                Text(
                  NumberFormat("#,###", "vi_VN")
                      .format(widget.productItem.price),
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
              ),
              PopupMenuItem(
                value: (widget.productItem.available) ? 'Disable' : "Enable",
                child: (widget.productItem.available)
                    ? Text('Disable')
                    : Text('Enable'),
              ),
            ],
            icon: Icon(Icons.more_vert_outlined),
          )
        ],
      ),
    );
  }
}
