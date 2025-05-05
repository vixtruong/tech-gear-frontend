import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/brand.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/product/product_admin_card.dart';

class ManageProductScreen extends StatefulWidget {
  const ManageProductScreen({super.key});

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;
  late BrandProvider _brandProvider;

  List<Product> _products = [];
  List<Category> _categories = [];
  List<Brand> _brands = [];

  bool _isLoading = true;
  String? _selectedBrandId;
  String? _selectedCategoryId;
  String? _selectedSortOption;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _productProvider.fetchProducts();
      await _categoryProvider.fetchCategories();
      await _brandProvider.fetchBrands();
      if (mounted) {
        setState(() {
          _products = _productProvider.products;
          _categories = _categoryProvider.categories;
          _brands = _brandProvider.brands;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red[400],
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();

  // Filter and sort products based on selected brand, category, and sort option
  List<Product> _getFilteredAndSortedProducts() {
    List<Product> filtered = _products;

    // Apply brand filter
    if (_selectedBrandId != null) {
      filtered = filtered
          .where((product) => product.brandId == _selectedBrandId)
          .toList();
    }

    // Apply category filter
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((product) => product.categoryId == _selectedCategoryId)
          .toList();
    }

    // Apply sorting
    switch (_selectedSortOption) {
      case 'name_asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        // Default order (no sorting, use original order)
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        animatedIcon: AnimatedIcons.menu_close,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        elevation: 10.0,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_circle, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Add New Product',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              if (kIsWeb) {
                context.go('/add-product');
              } else {
                context.push('/add-product');
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.block, color: Colors.white),
            backgroundColor: Colors.grey[400],
            label: 'Disabled Products',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              // TODO: Implement navigation to disabled products screen
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          _products = productProvider.products;
          final filteredProducts = _getFilteredAndSortedProducts();

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Text(
                'No products available for the selected filters.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        label: 'Brands',
                        hint: 'Select a brand',
                        items: [
                          {'id': null, 'name': 'All Brands'},
                          ..._brands.map(
                              (brand) => {'id': brand.id, 'name': brand.name}),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBrandId = value;
                          });
                        },
                        validator: (value) => null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomDropdown(
                        label: 'Categories',
                        hint: 'Select a category',
                        items: [
                          {'id': null, 'name': 'All Categories'},
                          ..._categories.map((category) =>
                              {'id': category.id, 'name': category.name}),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) => null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomDropdown(
                  label: 'Sort By',
                  hint: 'Select sort option',
                  items: [
                    {'id': null, 'name': 'Default'},
                    {'id': 'name_asc', 'name': 'Name (A-Z)'},
                    {'id': 'name_desc', 'name': 'Name (Z-A)'},
                    {'id': 'price_asc', 'name': 'Price (Low to High)'},
                    {'id': 'price_desc', 'name': 'Price (High to Low)'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSortOption = value;
                    });
                  },
                  validator: (value) => null,
                ),
                const SizedBox(height: 15),
                // Group products by category
                ..._categories.map((category) {
                  // Filter products for the current category
                  final categoryProducts = filteredProducts
                      .where((product) => product.categoryId == category.id)
                      .toList();

                  // Only display categories with products
                  if (categoryProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Products under this category
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryProducts.length,
                        itemBuilder: (context, index) {
                          return ProductAdminCard(
                            product: categoryProducts[index],
                          );
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
