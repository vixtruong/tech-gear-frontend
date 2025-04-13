import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added
import 'package:techgear/models/product/brand.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/models/product/group_product_specs.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/models/product/product_specification.dart';
import 'package:techgear/models/product/variant_value.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_config_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';
import 'package:techgear/ui/widgets/product/color_variant_box.dart';
import 'package:techgear/ui/widgets/product/specs_variant_box.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.isAdmin = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductProvider _productProvider;
  late ProductItemProvider _productItemProvider;
  late ProductConfigProvider _productConfigProvider;
  late VariantOptionProvider _variantOptionProvider;
  late VariantValueProvider _variantValueProvider;

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

  ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;

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

    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 10) {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
        }
      } else {
        if (_isExpanded) {
          setState(() {
            _isExpanded = false;
          });
        }
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: double.infinity,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCircleButton(
                icon: Icons.arrow_back_outlined,
                onTaped: () {
                  context.pop();
                },
              ),
              Spacer(),
              if (!widget.isAdmin)
                buildCircleButton(
                  icon: Icons.add_shopping_cart_outlined,
                  onTaped: () {},
                ),
              if (!widget.isAdmin) SizedBox(width: 10),
              if (!widget.isAdmin)
                buildCircleButton(
                  icon: Icons.favorite_outline,
                  onTaped: () {},
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.isAdmin || !_isDiscontinued
          ? null
          : BottomAppBar(
              surfaceTintColor: Colors.white,
              shadowColor: Colors.white,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      buildCounterButton(Icons.remove, () {
                        setState(() {
                          if (count > 1) count--;
                        });
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$count",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      buildCounterButton(Icons.add, () {
                        setState(() {
                          count++;
                        });
                      }),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("Add to Cart", Colors.blue,
                          (widget.isAdmin || !_isDiscontinued) ? null : () {}),
                      SizedBox(width: 8),
                      buildButton("Buy now", Colors.blue,
                          (widget.isAdmin || !_isDiscontinued) ? null : () {}),
                    ],
                  ),
                ],
              ),
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

          return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: PageView.builder(
                      itemCount: _productItems.length + 1,
                      itemBuilder: (context, index) {
                        final imageUrl = index == 0
                            ? product!.imgUrl
                            : _productItems[index - 1].imgUrl;
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
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
                        );
                      },
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.55,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    _scrollController = scrollController;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                buildTag(brand?.name ?? ""),
                                SizedBox(width: 5),
                                buildTag(category?.name ?? ""),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              product?.name ?? "",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              product?.description ?? "",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(height: 15),
                            if (colors.isNotEmpty && specs.isNotEmpty) ...[
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  for (var specs in groupedList)
                                    SpecsVariantBox(
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
                                ],
                              ),
                              if (selectedSpecs != null) ...[
                                const SizedBox(height: 15),
                                Text(
                                  "COLORS",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  spacing: 5,
                                  children: [
                                    for (var colorSpec in colorSpecsList)
                                      for (var entry in colorSpec.entries)
                                        for (var color in entry.value)
                                          ColorVariantBox(
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
                                  ],
                                ),
                              ],
                            ] else if (colors.isEmpty && specs.isNotEmpty) ...[
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  for (var spec in specs)
                                    for (var entry in spec.entries)
                                      for (var value in entry.value)
                                        ColorVariantBox(
                                          color: value,
                                          selectedProductItem: entry.key,
                                          isSelected: selectedItem == entry.key,
                                          onTap: () {
                                            setState(() {
                                              selectedItem = entry.key;
                                            });
                                          },
                                        ),
                                ],
                              ),
                            ] else if (colors.isNotEmpty && specs.isEmpty) ...[
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  for (var spec in colors)
                                    for (var entry in spec.entries)
                                      for (var value in entry.value)
                                        ColorVariantBox(
                                          color: value,
                                          selectedProductItem: entry.key,
                                          isSelected: selectedItem == entry.key,
                                          onTap: () {
                                            setState(() {
                                              selectedItem = entry.key;
                                            });
                                          },
                                        ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                "This product is discontinued.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildCounterButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: Colors.grey[300],
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 10,
      ),
    );
  }

  Widget buildCircleButton({
    required IconData icon,
    required VoidCallback onTaped,
  }) {
    return GestureDetector(
      onTap: onTaped,
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withAlpha((0.3 * 255).toInt()),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget buildButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
