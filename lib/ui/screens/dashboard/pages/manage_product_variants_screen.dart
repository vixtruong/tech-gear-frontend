import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
import 'package:techgear/ui/widgets/product/product_item_card.dart';

class ManageProductVariantsScreen extends StatefulWidget {
  final String productId;

  const ManageProductVariantsScreen({super.key, required this.productId});

  @override
  State<ManageProductVariantsScreen> createState() =>
      _ManageProductVariantsScreenState();
}

class _ManageProductVariantsScreenState
    extends State<ManageProductVariantsScreen> {
  late ProductItemProvider _productItemProvider;
  late ProductProvider _productProvider;

  List<ProductItem> _productItems = [];
  Product? product;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productItemProvider =
        Provider.of<ProductItemProvider>(context, listen: false);
    _productProvider = Provider.of<ProductProvider>(context, listen: false);

    _loadProductItems();
  }

  Future<void> _loadProductItems() async {
    try {
      await _productItemProvider.fetchProductItemsByProductId(widget.productId);
      var fetchedProduct =
          await _productProvider.fetchProductById(widget.productId);
      setState(() {
        product = fetchedProduct;

        _productItems.sort((a, b) {
          return b.createdAt!.millisecondsSinceEpoch -
              a.createdAt!.millisecondsSinceEpoch;
        });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        title: Text(
          product?.name ?? "Manage Product Variants",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/add-product-variants/${widget.productId}');
            },
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Consumer<ProductItemProvider>(
        builder: (context, variantOptionProvider, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          _productItemProvider.fetchProductItemsByProductId(widget.productId);
          _productItems = _productItemProvider.productItems;
          return SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: TextEditingController(),
                  hint: "Search",
                  inputType: TextInputType.text,
                  isSearch: true,
                ),
                SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _productItems.length,
                  itemBuilder: (context, index) =>
                      ProductItemCard(productItem: _productItems[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
