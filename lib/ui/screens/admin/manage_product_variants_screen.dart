import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/models/product_item.dart';
import 'package:techgear/providers/product_item_provider.dart';
import 'package:techgear/providers/product_provider.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';
import 'package:techgear/ui/widgets/product_item_card.dart';

class ManageProductVariantsScreen extends StatefulWidget {
  final String productId;

  const ManageProductVariantsScreen({super.key, required this.productId});

  @override
  State<ManageProductVariantsScreen> createState() =>
      _ManageProductVariantsScreenState();
}

class _ManageProductVariantsScreenState
    extends State<ManageProductVariantsScreen> {
  final ProductItemProvider _productItemProvider = ProductItemProvider();
  final ProductProvider _productProvider = ProductProvider();
  List<ProductItem> _productItems = [];
  Product? product;

  @override
  void initState() {
    super.initState();
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

        _productItems = _productItemProvider.productItems;
      });
    } catch (e) {}
  }

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
          product?.name ?? "Manage Product Variants",
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
            label: 'Add Product Variant',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              context.push('/add-product-variants/${widget.productId}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
      ),
    );
  }
}
