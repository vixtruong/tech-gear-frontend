import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/product/product_card.dart';
import 'package:flutter/foundation.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final List<Product> cartItems = [];

  final Map<int, double> _offsets = {};

  // final bool _isSelectAll = false;

  int itemChecks = 10;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          leading: kIsWeb
              ? null
              : GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Icon(Icons.arrow_back_outlined)),
          title: const Text(
            "Wishlist",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomDropdown(
                      label: "Sort by",
                      items: [],
                      onChanged: (value) {},
                    ),
                    const SizedBox(width: 8),
                    CustomDropdown(
                      label: "Categories",
                      items: [],
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0,
                    mainAxisExtent: 265,
                  ),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    _offsets.putIfAbsent(index, () => 0.0);

                    return GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _offsets[index] =
                              (_offsets[index]! + details.primaryDelta!)
                                  .clamp(-80.0, 0.0);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        setState(() {
                          _offsets[index] =
                              (_offsets[index]! < -40) ? -80.0 : 0.0;
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
                            transform: Matrix4.translationValues(
                                _offsets[index]!, 0, 0),
                            child: ProductCard(
                              product: product,
                              atHome: false,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
