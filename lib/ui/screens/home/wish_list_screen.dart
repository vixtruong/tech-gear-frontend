import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final List<Product> wishListItems = [
    // Sample data for testing
  ];

  final Map<int, ValueNotifier<double>> _offsets = {};
  bool _isSelectAll = false;
  int itemChecks = 10;

  @override
  void dispose() {
    for (var notifier in _offsets.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      final product = wishListItems[index];
      wishListItems.removeAt(index);
      final notifier = _offsets.remove(index);
      notifier?.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${product.name} removed from wishlist",
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[200],
        ),
      );
    });
  }

  double getTotalPrice() {
    return wishListItems.fold(0, (sum, item) => sum + item.price);
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
                child: const Icon(Icons.arrow_back_outlined),
              ),
        title: const Text(
          "Wishlist",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: kIsWeb
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
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
                          Row(
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
                        ],
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
      itemCount: wishListItems.length,
      itemBuilder: (context, index) {
        // final product = wishListItems[index];
        _offsets.putIfAbsent(index, () => ValueNotifier<double>(0.0));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final notifier = _offsets[index]!;
            notifier.value =
                (notifier.value + details.primaryDelta!).clamp(-80.0, 0.0);
          },
          onHorizontalDragEnd: (details) {
            final notifier = _offsets[index]!;
            notifier.value = (notifier.value < -40) ? -80.0 : 0.0;
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
              ValueListenableBuilder<double>(
                valueListenable: _offsets[index]!,
                builder: (context, offset, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(offset, 0, 0),
                    // child: CartItemCard(productItemId: 1),
                  );
                },
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
              // Wishlist Items Table
              Expanded(
                flex: 3,
                child: wishListItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Your wishlist is empty",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.go('/home'); // Adjust route
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Back to Home",
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
                          // Filters
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                          // Table Header
                          Container(
                            padding: const EdgeInsets.all(12),
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
                                const SizedBox(width: 40), // For checkbox
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Product",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Price",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 60), // For delete button
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Wishlist Items
                          ...List.generate(wishListItems.length, (index) {
                            final product = wishListItems[index];
                            return MouseRegion(
                              onEnter: (_) {
                                // Optional: Add hover effect
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
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
                                    // Expanded(
                                    //   flex: 3,
                                    //   // child: CartItemCard(
                                    //   //   productItemId: 1,
                                    //   // ),
                                    // ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${product.price}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => _removeItem(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
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
              const SizedBox(width: 32),
              // Wishlist Summary Sidebar
              if (wishListItems.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                        const Text(
                          "Wishlist Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Items",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "${wishListItems.length}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Value",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "${getTotalPrice()}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add logic to add selected items to cart
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Add to Cart ($itemChecks)",
                              style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Value",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  "${getTotalPrice()}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Add logic to add selected items to cart
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                "Add to Cart ($itemChecks)",
                style: const TextStyle(
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
