import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/models/product/brand.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/models/product/group_product_specs.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/models/product/product_specification.dart';
import 'package:techgear/models/product/variant_value.dart';
import 'package:techgear/providers/order_providers/cart_provider.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_config_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';
import 'package:techgear/ui/widgets/product/color_variant_box.dart';
import 'package:techgear/ui/widgets/product/specs_variant_box.dart';

class ProductDetailScreenWeb extends StatefulWidget {
  final String productId;
  final bool isAdmin;

  const ProductDetailScreenWeb({
    super.key,
    required this.productId,
    this.isAdmin = false,
  });

  @override
  State<ProductDetailScreenWeb> createState() => _ProductDetailScreenWebState();
}

class _ProductDetailScreenWebState extends State<ProductDetailScreenWeb> {
  late ProductProvider _productProvider;
  late ProductItemProvider _productItemProvider;
  late ProductConfigProvider _productConfigProvider;
  late VariantOptionProvider _variantOptionProvider;
  late VariantValueProvider _variantValueProvider;
  late CartProvider _cartProvider;

  late CategoryProvider _categoryProvider;
  late BrandProvider _brandProvider;
  Product? product;
  late ProductSpecification productSpec;
  Category? category;
  Brand? brand;

  List<ProductItem> _productItems = [];
  List<Map<ProductItem, List<VariantValue>>> specs = [];
  List<Map<ProductItem, List<VariantValue>>> colors = [];

  List<GroupProductSpecs> groupedList = [];
  List<Map<ProductItem, List<VariantValue>>> colorSpecsList = [];

  bool _isLoading = true;
  bool _isDiscontinued = true;
  String? centerImageUrl;

  GroupProductSpecs? selectedSpecs;
  ProductItem? selectedItem;

  int count = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _productItemProvider =
        Provider.of<ProductItemProvider>(context, listen: false);
    _productConfigProvider =
        Provider.of<ProductConfigProvider>(context, listen: false);
    _variantOptionProvider =
        Provider.of<VariantOptionProvider>(context, listen: false);
    _variantValueProvider =
        Provider.of<VariantValueProvider>(context, listen: false);
    _cartProvider = Provider.of<CartProvider>(context, listen: false);

    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productFuture = _productProvider.fetchProductById(widget.productId);
      final categoryFuture = productFuture
          .then((p) => _categoryProvider.fetchCategoryById(p!.categoryId));
      final brandFuture =
          productFuture.then((p) => _brandProvider.fetchBrandById(p!.brandId));
      final itemsFuture =
          _productItemProvider.fetchProductItemsByProductId(widget.productId);

      final results = await Future.wait(
          [productFuture, categoryFuture, brandFuture, itemsFuture]);

      product = results[0] as Product?;
      category = results[1] as Category?;
      brand = results[2] as Brand?;
      _productItems = _productItemProvider.productItems;

      List<Future<void>> configFutures = [];
      for (var item in _productItems) {
        configFutures.add(_fetchProductConfig(item));
      }
      await Future.wait(configFutures);

      productSpec = ProductSpecification(
          productId: widget.productId, specs: specs, colors: colors);

      if (specs.isEmpty && colors.isEmpty) {
        setState(() {
          _isLoading = false;
          _isDiscontinued = false;
        });
        return;
      }

      groupProductItemsBySpecs();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (groupedList.isNotEmpty) {
          selectedSpecs = groupedList.first;
        }
      });

      if (colors.isNotEmpty) {
        colorSpecsList = getColorsForSelectedSpecs();
        if (colorSpecsList.isNotEmpty) {
          var firstEntry = colorSpecsList.first.entries.first;
          setState(() {
            selectedItem = firstEntry.key;
          });
        }
      } else {
        setState(() {
          selectedItem = specs.first.entries.first.key;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red[400]),
      );
    }
  }

  Future<void> _fetchProductConfig(ProductItem item) async {
    await _productConfigProvider.fetchProductConfigsByProductItemId(item.id!);
    List<VariantValue> valuesList = [];
    List<VariantValue> colorsList = [];
    for (var config in _productConfigProvider.productConfigs) {
      var value = await _variantValueProvider
          .fetchVariantValueById(config.variantValueId);
      var option = await _variantOptionProvider
          .fetchVariantOptionById(value!.variantOptionId);
      if (option != null && option.name.toLowerCase() == "color") {
        colorsList.add(value);
      } else {
        valuesList.add(value);
      }
    }

    if (colorsList.isNotEmpty) {
      colors.add({item: colorsList});
    }

    if (valuesList.isNotEmpty) {
      specs.add({item: valuesList});
    }
  }

  void groupProductItemsBySpecs() {
    Map<String, GroupProductSpecs> groupedMap = {};

    for (var spec in productSpec.specs) {
      for (var entry in spec.entries) {
        ProductItem productItem = entry.key;
        List<VariantValue> variantValues = entry.value;

        List<String> sortedVariantIds = variantValues.map((v) => v.id).toList();
        sortedVariantIds.sort();
        String key = sortedVariantIds.join("-");

        if (groupedMap.containsKey(key)) {
          groupedMap[key]!.productItems.add(productItem);
        } else {
          groupedMap[key] = GroupProductSpecs(
            productItems: [productItem],
            specs: variantValues,
          );
        }
      }
    }

    groupedList = groupedMap.values.toList();
  }

  List<Map<ProductItem, List<VariantValue>>> getColorsForSelectedSpecs() {
    if (selectedSpecs == null || productSpec.colors == null) return [];

    List<Map<ProductItem, List<VariantValue>>> list = [];

    for (var colorsSpec in productSpec.colors!) {
      for (var entry in colorsSpec.entries) {
        if (selectedSpecs!.productItems.contains(entry.key)) {
          list.add({entry.key: entry.value});
        }
      }
    }

    return list;
  }

  Future<void> _addToCart(String productItemId, int count) async {
    try {
      var cartItem = CartItem(productItemId: productItemId, quantity: count);
      await _cartProvider.addItem(cartItem);

      var productItem =
          _productItems.firstWhere((item) => item.id == productItemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${productItem.sku} added to cart"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add to cart: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          product?.name ?? "Product Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!widget.isAdmin)
            IconButton(
              icon: Icon(Icons.favorite_outline),
              onPressed: () {},
              tooltip: "Add to Wishlist",
            ),
          SizedBox(width: 16),
        ],
      ),
      body: Consumer<ProductItemProvider>(
        builder: (context, productItemProvider, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          productItemProvider.fetchProductItemsByProductId(widget.productId);
          _productItems = productItemProvider.productItems;
          colorSpecsList = getColorsForSelectedSpecs();

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 1200 ? 100 : 20,
                    vertical: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Images
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              height: 500,
                              decoration: BoxDecoration(
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
                              child: CachedNetworkImage(
                                imageUrl:
                                    selectedItem?.imgUrl ?? product!.imgUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _productItems.length + 1,
                                itemBuilder: (context, index) {
                                  final imageUrl = index == 0
                                      ? product!.imgUrl
                                      : _productItems[index - 1].imgUrl;
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            centerImageUrl = imageUrl;
                                          });
                                        },
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: centerImageUrl == imageUrl
                                                  ? Colors.blue
                                                  : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey[400],
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32),
                      // Right: Product Details
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                buildTag(brand?.name ?? ""),
                                SizedBox(width: 8),
                                buildTag(category?.name ?? ""),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              product?.name ?? "",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product?.description ?? "",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 24),
                            if (colors.isNotEmpty && specs.isNotEmpty) ...[
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var specs in groupedList)
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: SpecsVariantBox(
                                        specs: specs,
                                        isSelect: selectedSpecs == specs,
                                        onTap: () {
                                          setState(() {
                                            if (selectedSpecs == specs) return;
                                            selectedSpecs = specs;
                                            colorSpecsList =
                                                getColorsForSelectedSpecs();
                                            if (colorSpecsList.isNotEmpty) {
                                              var firstEntry = colorSpecsList
                                                  .first.entries.first;
                                              selectedItem = firstEntry.key;
                                            } else {
                                              selectedItem = null;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              if (selectedSpecs != null) ...[
                                SizedBox(height: 16),
                                Text(
                                  "COLORS",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (var colorSpec in colorSpecsList)
                                      for (var entry in colorSpec.entries)
                                        for (var color in entry.value)
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: ColorVariantBox(
                                              color: color,
                                              selectedProductItem: entry.key,
                                              isSelected:
                                                  selectedItem == entry.key,
                                              onTap: () {
                                                setState(() {
                                                  selectedItem = entry.key;
                                                });
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ] else if (colors.isEmpty && specs.isNotEmpty) ...[
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var spec in specs)
                                    for (var entry in spec.entries)
                                      for (var value in entry.value)
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: ColorVariantBox(
                                            color: value,
                                            selectedProductItem: entry.key,
                                            isSelected:
                                                selectedItem == entry.key,
                                            onTap: () {
                                              setState(() {
                                                selectedItem = entry.key;
                                              });
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ] else if (colors.isNotEmpty && specs.isEmpty) ...[
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var spec in colors)
                                    for (var entry in spec.entries)
                                      for (var value in entry.value)
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: ColorVariantBox(
                                            color: value,
                                            selectedProductItem: entry.key,
                                            isSelected:
                                                selectedItem == entry.key,
                                            onTap: () {
                                              setState(() {
                                                selectedItem = entry.key;
                                              });
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                "This product is discontinued.",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                            if (!widget.isAdmin && _isDiscontinued) ...[
                              SizedBox(height: 24),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      buildCounterButton(Icons.remove, () {
                                        setState(() {
                                          if (count > 1) count--;
                                        });
                                      }),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          "$count",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      buildCounterButton(Icons.add, () {
                                        setState(() {
                                          count++;
                                        });
                                      }),
                                    ],
                                  ),
                                  SizedBox(width: 32),
                                  Expanded(
                                    child: buildButton(
                                      "Add to Cart",
                                      Colors.blue,
                                      () =>
                                          _addToCart(selectedItem!.id!, count),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: buildButton(
                                      "Buy Now",
                                      Colors.green,
                                      () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildCounterButton(IconData icon, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget buildButton(String text, Color color, VoidCallback? onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
