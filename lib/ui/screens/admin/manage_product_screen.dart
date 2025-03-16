import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/brand.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/ui/widgets/custom_dropdown.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';
import 'package:techgear/ui/widgets/product_admin_card.dart';

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

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      await _productProvider.fetchProducts();
      await _categoryProvider.fetchCategories();
      await _brandProvider.fetchBrands();
      setState(() {
        // _products = _productProvider.products;
        _categories = _categoryProvider.categories;
        _brands = _brandProvider.brands;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red[400]),
        );
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Icon(Icons.arrow_back_outlined),
        ),
        title: Text(
          "Manage Product (${_products.length})",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white, // Màu nền trắng
        foregroundColor: Colors.black,
        animatedIcon: AnimatedIcons.menu_close,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 10.0,
        children: [
          SpeedDialChild(
            child: Icon(Icons.settings, color: Colors.white),
            backgroundColor: Colors.blueGrey,
            label: 'Manage Variant Option',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              context.push('/manage-variant-options');
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add_circle, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Add New Product',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              context.push('/add-product');
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.block, color: Colors.white),
            backgroundColor: Colors.grey[400],
            label: 'Disabled Products',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              // context.push('/add-product');
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          _products = productProvider.products;
          return SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: _searchController,
                  hint: "Search",
                  isSearch: true,
                  inputType: TextInputType.text,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    CustomDropdown(
                      label: "Brands",
                      hint: "Select a brand",
                      items: _brands
                          .map((brand) => {'id': brand.id, 'name': brand.name})
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please choose brand";
                        }
                        return null;
                      },
                    ),
                    SizedBox(width: 10),
                    CustomDropdown(
                      label: "Categories",
                      hint: "Select a category",
                      items: _categories
                          .map((category) =>
                              {'id': category.id, 'name': category.name})
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please choose category";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15),
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
}
