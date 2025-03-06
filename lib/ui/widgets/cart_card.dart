import 'package:flutter/material.dart';
import 'package:techgear/data/models/product.dart';

class CartCard extends StatefulWidget {
  final Product product;

  const CartCard({super.key, required this.product});

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  int count = 1;
  bool isCheck = false;

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
          Checkbox(
            activeColor: Colors.orange,
            value: isCheck,
            onChanged: (value) {
              setState(() {
                isCheck = value!;
              });
            },
          ),
          Image.network(
            'https://product.hstatic.net/200000378371/product/3q7a0426_6cc0d552e49b41babc4d82a0a056ef45_master.jpg',
            height: 100,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name),
                Text("${widget.product.colors}"),
                Text("${widget.product.price}"),
              ],
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      count++;
                    });
                  },
                  icon: Icon(Icons.add),
                  iconSize: 8,
                ),
              ),
              Text("$count"),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (count > 1) {
                        count--;
                      }
                    });
                  },
                  icon: Icon(Icons.remove),
                  iconSize: 8,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
