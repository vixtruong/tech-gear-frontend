import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/product_item_info_dto.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/providers/cart_providers/cart_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/ui/widgets/cart/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;
  late ProductItemProvider _productItemProvider;

  List<ProductItemInfoDto> _productItemInfos = [];
  List<CartItem> _cartItems = [];
  final Map<int, ValueNotifier<double>> _offsets = {};
  final Map<int, bool> _selectedItems = {};
  bool _isSelectAll = false;
  bool _isLoading = true;
  bool _hasLoaded = false;

  final vndFormat = NumberFormat.decimalPattern('vi_VN');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
    _productItemProvider =
        Provider.of<ProductItemProvider>(context, listen: false);

    if (!_hasLoaded) {
      _loadInformations();
      _hasLoaded = true;
    }
  }

  Future<void> _loadInformations() async {
    try {
      setState(() => _isLoading = true);
      await _cartProvider.loadCartFromStorage();

      _cartItems = _cartProvider.items;
      if (_cartItems.isEmpty) {
        setState(() {
          _productItemInfos = [];
          _cartItems = [];
          _selectedItems.clear();
          _isLoading = false;
        });
        return;
      }

      var productItemIds = _cartItems
          .map((item) {
            try {
              return int.parse(item.productItemId);
            } catch (e) {
              debugPrint('Error parsing productItemId for cart item: $e');
              return -1;
            }
          })
          .where((id) => id != -1)
          .toList();

      if (productItemIds.isEmpty) {
        setState(() {
          _productItemInfos = [];
          _cartItems = [];
          _selectedItems.clear();
          _isLoading = false;
        });
        return;
      }

      var productItemInfos =
          await _productItemProvider.fetchProductItemsByIds(productItemIds);

      setState(() {
        _productItemInfos = productItemInfos ?? [];
        final List<CartItem> filteredCartItems = [];
        final List<ProductItemInfoDto> filteredProductInfos = [];
        for (var cartItem in _cartItems) {
          var productInfo = _productItemInfos.firstWhere(
            (info) => info.productItemId == int.parse(cartItem.productItemId),
            orElse: () => ProductItemInfoDto(
              productItemId: -1,
              productName: '',
              sku: '',
              imgUrl: '',
              price: 0.0,
            ),
          );
          if (productInfo.productItemId != -1) {
            filteredCartItems.add(cartItem);
            filteredProductInfos.add(productInfo);
          }
        }
        _cartItems = filteredCartItems;
        _productItemInfos = filteredProductInfos;
        _selectedItems.clear();
        _offsets.clear(); // Clear previous offsets
        for (var i = 0; i < _cartItems.length; i++) {
          _selectedItems[i] = false;
          _offsets[i] =
              ValueNotifier<double>(0.0); // Initialize offset for each index
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load cart: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error loading cart: $e');
    }
  }

  @override
  void dispose() {
    for (var notifier in _offsets.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _removeItem(int index) async {
    final cartItem = _cartItems[index];
    final product = _productItemInfos[index];
    try {
      final removedIndex = index;
      final removedCartItem = cartItem;
      final removedProduct = product;

      debugPrint('Removing item: ${cartItem.productItemId}');

      setState(() {
        _cartItems.removeAt(index);
        _productItemInfos.removeAt(index);
        _selectedItems.remove(index);
        _offsets.remove(index)?.dispose();

        // Rebuild the maps with new indices
        final newOffsets = <int, ValueNotifier<double>>{};
        final newSelectedItems = <int, bool>{};
        for (var i = 0; i < _cartItems.length; i++) {
          newOffsets[i] =
              _offsets[i + (i >= index ? 1 : 0)] ?? ValueNotifier<double>(0.0);
          newSelectedItems[i] =
              _selectedItems[i + (i >= index ? 1 : 0)] ?? false;
        }
        _offsets.clear();
        _offsets.addAll(newOffsets);
        _selectedItems.clear();
        _selectedItems.addAll(newSelectedItems);
      });

      await _cartProvider.removeItem(cartItem.productItemId);

      debugPrint('Item removed successfully: ${cartItem.productItemId}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${product.productName} removed from cart",
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.grey[200],
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                setState(() {
                  _cartItems.insert(removedIndex, removedCartItem);
                  _productItemInfos.insert(removedIndex, removedProduct);
                  _selectedItems[removedIndex] = false;
                  _offsets[removedIndex] =
                      ValueNotifier<double>(0.0); // Reinitialize offset
                });
                await _cartProvider.addItem(removedCartItem);
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _cartItems.insert(index, cartItem);
        _productItemInfos.insert(index, product);
        _selectedItems[index] = false;
        _offsets[index] = ValueNotifier<double>(0.0); // Reinitialize offset
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove item: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error removing item: $e');
    }
  }

  Future<void> _updateQuantity(int index, bool increase) async {
    try {
      final cartItem = _cartItems[index];
      await _cartProvider.updateQuantity(cartItem.productItemId, increase);
      setState(() {
        _cartItems = _cartProvider.items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update quantity: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error updating quantity: $e');
    }
  }

  double getTotalPrice() {
    double total = 0;
    for (int i = 0; i < _cartItems.length; i++) {
      if (_selectedItems[i] ?? false) {
        total += _productItemInfos[i].price * _cartItems[i].quantity;
      }
    }
    return total;
  }

  int getSelectedItemCount() {
    return _selectedItems.values.where((isSelected) => isSelected).length;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: kIsWeb ? 1 : 0,
        leading: kIsWeb
            ? null
            : GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_outlined),
              ),
        title: const Text(
          "Shopping Cart",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: isWeb
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
                            _selectedItems.updateAll((key, _) => _isSelectAll);
                          });
                        },
                      ),
                      const Text("Select All", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ]
            : null,
        bottom: isWeb
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.orange,
                        value: _isSelectAll,
                        onChanged: (value) {
                          setState(() {
                            _isSelectAll = value!;
                            _selectedItems.updateAll((key, _) => _isSelectAll);
                          });
                        },
                      ),
                      const Text("Select All", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWeb
              ? _buildWebBody(context)
              : _buildMobileBody(context),
      bottomNavigationBar: isWeb ? null : _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15.0),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = _cartItems[index];
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
                      width: 80,
                      height: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
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
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            activeColor: Colors.orange,
                            value: _selectedItems[index] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _selectedItems[index] = value!;
                                _isSelectAll = _selectedItems.values
                                    .every((selected) => selected);
                              });
                            },
                          ),
                          Expanded(
                            child: CartItemCard(
                              productItemId: int.parse(cartItem.productItemId),
                              quantity: cartItem.quantity,
                              onIncrease: () => _updateQuantity(index, true),
                              onDecrease: () => _updateQuantity(index, false),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              Expanded(
                flex: 3,
                child: _cartItems.isEmpty || _productItemInfos.isEmpty
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
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 40),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "Product",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Quantity",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Price",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 85),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_cartItems.length, (index) {
                            final product = _productItemInfos[index];
                            final cartItem = _cartItems[index];
                            return MouseRegion(
                              onEnter: (_) {},
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
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
                                      value: _selectedItems[index] ?? false,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedItems[index] = value!;
                                          _isSelectAll = _selectedItems.values
                                              .every((selected) => selected);
                                        });
                                      },
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: CartItemCard(
                                          productItemId:
                                              int.parse(cartItem.productItemId),
                                          quantity: cartItem.quantity),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 20),
                                            onPressed: () =>
                                                _updateQuantity(index, false),
                                          ),
                                          Text("${cartItem.quantity}"),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.add, size: 20),
                                            onPressed: () =>
                                                _updateQuantity(index, true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${vndFormat.format(product.price * cartItem.quantity)}đ",
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
                                    SizedBox(
                                      width: 30,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
              ),
              const SizedBox(width: 32),
              if (_cartItems.isNotEmpty && _productItemInfos.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
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
                          "Order Summary",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Subtotal",
                                style: TextStyle(fontSize: 16)),
                            Text(vndFormat.format(getTotalPrice()),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Shipping", style: TextStyle(fontSize: 16)),
                            Text("TBD", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              vndFormat.format(getTotalPrice()),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: getSelectedItemCount() == 0
                                ? null
                                : () => context.go('/checkout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Checkout (${getSelectedItemCount()})",
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
    final vndFormat = NumberFormat.decimalPattern('vi_VN');
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
                  "Total Price",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${vndFormat.format(getTotalPrice())}đ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: getSelectedItemCount() == 0
                  ? null
                  : () => context.go('/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                "Buy (${getSelectedItemCount()})",
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
