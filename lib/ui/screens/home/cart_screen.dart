import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/ui/widgets/cart/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Product> cartItems = [
    // Sample data for testing
  ];

  final Map<int, double> _offsets = {};
  bool _isSelectAll = false;
  int itemChecks = 10;

  void _removeItem(int index) {
    setState(() {
      final product = cartItems[index];
      cartItems.removeAt(index);
      _offsets.remove(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${product.name} removed",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[200],
        ),
      );
    });
  }

  double getTotalPrice() {
    return cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: kIsWeb ? 1 : 0,
        leading: kIsWeb
            ? null
            : GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Icon(Icons.arrow_back_outlined),
              ),
        title: const Text(
          "Shopping Cart",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: kIsWeb
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
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
              ]
            : null,
        bottom: kIsWeb
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSelectAll = !_isSelectAll;
                          });
                        },
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
                            const Text("Select All",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      body: kIsWeb ? _buildWebBody(context) : _buildMobileBody(context),
      bottomNavigationBar: kIsWeb ? null : _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        // final product = cartItems[index];
        _offsets.putIfAbsent(index, () => 0.0);

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _offsets[index] =
                  (_offsets[index]! + details.primaryDelta!).clamp(-80.0, 0.0);
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
                    onTap: () => _removeItem(index),
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
                transform: Matrix4.translationValues(_offsets[index]!, 0, 0),
                child: CartItemCard(productItemId: 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth > 1200 ? 100.0 : 20.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart Items Table
              Expanded(
                flex: 3,
                child: cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Your cart is empty",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.go('/home'); // Adjust route
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Shop Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table Header
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 40), // For checkbox
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Product",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Quantity",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Price",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 60), // For delete button
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          // Cart Items
                          ...List.generate(cartItems.length, (index) {
                            final product = cartItems[index];
                            return MouseRegion(
                              onEnter: (_) {
                                // Optional: Add hover effect
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: Colors.orange,
                                      value:
                                          _isSelectAll, // Update with per-item logic
                                      onChanged: (value) {
                                        setState(() {
                                          // Add per-item selection logic
                                        });
                                      },
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: CartItemCard(productItemId: 1),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove, size: 20),
                                            onPressed: () {
                                              // Update quantity
                                            },
                                          ),
                                          Text("1"), // Replace with dynamic
                                          IconButton(
                                            icon: Icon(Icons.add, size: 20),
                                            onPressed: () {
                                              // Update quantity
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${product.price}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => _removeItem(index),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
              ),
              SizedBox(width: 32),
              // Order Summary Sidebar
              if (cartItems.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "${getTotalPrice()}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shipping",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "TBD", // Replace with dynamic
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${getTotalPrice()}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Checkout ($itemChecks)",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
      color: Colors.white,
      height: 70,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Price",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  "${getTotalPrice()}",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                "Buy ($itemChecks)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
