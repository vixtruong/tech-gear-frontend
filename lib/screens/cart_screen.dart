import 'package:flutter/material.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/widgets/cart_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Product> cartItems = [
    Product(name: "T Shirt", colors: 5, price: 300, rating: 10),
    Product(name: "Jeans", colors: 3, price: 500, rating: 20),
    Product(name: "Sneakers", colors: 2, price: 700, rating: 30),
    Product(name: "T Shirt", colors: 5, price: 300, rating: 10),
    Product(name: "Jeans", colors: 3, price: 500, rating: 20),
    Product(name: "Sneakers", colors: 2, price: 700, rating: 30),
    Product(name: "T Shirt", colors: 5, price: 300, rating: 10),
    Product(name: "Jeans", colors: 3, price: 500, rating: 20),
    Product(name: "Sneakers", colors: 2, price: 700, rating: 30),
    Product(name: "T Shirt", colors: 5, price: 300, rating: 10),
    Product(name: "Jeans", colors: 3, price: 500, rating: 20),
    Product(name: "Sneakers", colors: 2, price: 700, rating: 30),
  ];

  final Map<int, double> _offsets = {};

  bool _isSelectAll = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          leadingWidth: 110,
          leading: Container(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
          ),
          title: const Text(
            "Shopping Cart",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.orange,
                        value: _isSelectAll,
                        onChanged: (value) {
                          setState(() {
                            _isSelectAll = value!;
                          });
                        },
                      ),
                      const Text("Select All", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final product = cartItems[index];
            _offsets.putIfAbsent(index, () => 0.0);

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _offsets[index] = (_offsets[index]! + details.primaryDelta!)
                      .clamp(-80.0, 0.0);
                });
              },
              onHorizontalDragEnd: (details) {
                setState(() {
                  _offsets[index] = (_offsets[index]! < -40) ? -80.0 : 0.0;
                });
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            cartItems.removeAt(index);
                            _offsets.remove(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${product.name} removed",
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Colors.grey[200],
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          width: 80,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform:
                        Matrix4.translationValues(_offsets[index]!, 0, 0),
                    child: CartCard(product: product),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Price"),
                    Text(
                      "20000",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    "Buy",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
