import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/brand.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/providers/brand_provider.dart';
import 'package:techgear/providers/category_provider.dart';
import 'package:techgear/providers/product_provider.dart';
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
    } catch (e) {}
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
            // context.pop();
          },
          child: Icon(Icons.arrow_back_outlined),
        ),
        title: Text(
          "Manage Product (${_products.length})",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/add-product');
            },
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.products.isEmpty && _isLoading) {
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
                      items: _brands.map((brand) => brand.name).toList(),
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
                      items:
                          _categories.map((category) => category.name).toList(),
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
