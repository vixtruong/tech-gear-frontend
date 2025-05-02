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
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
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
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // appBar: AppBar(
      //   surfaceTintColor: Colors.white,
      //   backgroundColor: Colors.white,
      //   shadowColor: Colors.white,
      //   title: Text(
      //     "Manage Product (${_products.length})",
      //     style: const TextStyle(fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      // ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        animatedIcon: AnimatedIcons.menu_close,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        elevation: 10.0,
        children: [
          // SpeedDialChild(
          //   child: const Icon(Icons.settings, color: Colors.white),
          //   backgroundColor: Colors.blueGrey,
          //   label: 'Manage Variant Option',
          //   labelStyle: const TextStyle(fontSize: 16),
          //   onTap: () {
          //     context.push('/manage-variant-options');
          //   },
          // ),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: _searchController,
                  hint: "Search",
                  isSearch: true,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        label: "Brands",
                        hint: "Select a brand",
                        items: _brands
                            .map(
                                (brand) => {'id': brand.id, 'name': brand.name})
                            .toList(),
                        validator: (value) {
                          return null; // Optional selection
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomDropdown(
                        label: "Categories",
                        hint: "Select a category",
                        items: _categories
                            .map((category) =>
                                {'id': category.id, 'name': category.name})
                            .toList(),
                        validator: (value) {
                          return null; // Optional selection
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return ProductAdminCard(
                      product: _products[index],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
