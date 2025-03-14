import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/providers/product_provider.dart';
import 'package:techgear/ui/widgets/custom_dropdown.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';
import 'package:techgear/ui/widgets/product_card.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductProvider _productProvider = ProductProvider();
  List<Product> _products = [];

  final TextEditingController _searchController = TextEditingController();

  final int cartItemCount = 3;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      await _productProvider.fetchProducts();
      setState(() {
        _products = _productProvider.products;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          leadingWidth: double.infinity,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _searchController,
                        hint: "Search",
                        isSearch: true,
                        inputType: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.push('/manage-product');
                        },
                        icon: Icon(Icons.favorite_border),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.push('/cart');
                        },
                        icon: badges.Badge(
                            badgeContent: Text(
                              '$cartItemCount',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                            child: Icon(Icons.shopping_cart_outlined)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomDropdown(
                    label: "Sort by",
                    items: ["Name", "Best Selling"],
                    onChanged: (value) {},
                  ),
                  const SizedBox(width: 8),
                  CustomDropdown(
                    label: "Categories",
                    items: ["T Shirt", "Jeans"],
                    onChanged: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPriceFilter("Under \$50"),
                    SizedBox(width: 5),
                    _buildPriceFilter("\$50 - \$100"),
                    SizedBox(width: 5),
                    _buildPriceFilter("\$100 - \$200"),
                    SizedBox(width: 5),
                    _buildPriceFilter("Above \$200"),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 255,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _products[index], atHome: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceFilter(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
