import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:techgear/models/brand.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/providers/brand_provider.dart';
import 'package:techgear/providers/category_provider.dart';
import 'package:techgear/providers/product_provider.dart';
import 'package:techgear/utils/url_helper.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductProvider _productProvider = ProductProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final BrandProvider _brandProvider = BrandProvider();
  Product? product;
  Category? category;
  Brand? brand;

  String? imgUrl;

  Future<void> _loadProduct() async {
    try {
      product = await _productProvider.fetchProductById(widget.productId);

      category = await _categoryProvider.fetchCategoryById(product!.categoryId);

      brand = await _brandProvider.fetchBrandById(product!.brandId);

      imgUrl = UrlHelper.getGoogleDriveImageUrl(product!.imgUrl);

      setState(() {});
    } catch (e) {}
  }

  ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;

  int count = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCircleButton(
                icon: Icons.arrow_back_outlined,
                onTaped: () {
                  context.pop();
                },
              ),
              buildCircleButton(
                icon: Icons.favorite_outline,
                onTaped: () {},
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: (product == null)
            ? Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ))
            : Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.network(
                      imgUrl!,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: double.infinity,
                    ),
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.55, // Mặc định hiển thị 40% màn hình
                    minChildSize: 0.5, // Có thể thu nhỏ đến 30% màn hình
                    maxChildSize: 0.7, // Có thể kéo lên đến 90% màn hình
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
                              Text(
                                "VARIANTS",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  buildColorOption(Colors.orange, true),
                                  buildColorOption(Colors.black, false),
                                  buildColorOption(Colors.blue, false),
                                  buildColorOption(Colors.grey, false),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  buildCounterButton(Icons.remove, () {
                                    setState(() {
                                      if (count > 1) count--;
                                    });
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text("$count"),
                                  ),
                                  buildCounterButton(Icons.add, () {
                                    setState(() {
                                      count++;
                                    });
                                  }),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    NumberFormat("#,###", "vi_VN")
                                        .format(product?.price ?? 0),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      buildButton("Buy Now", Colors.blue),
                                      const SizedBox(width: 8),
                                      buildButton("Add to Cart", Colors.blue),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
      radius: 12,
      backgroundColor: Colors.grey[300],
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 10,
      ),
    );
  }

  Widget buildCircleButton(
      {required IconData icon, required VoidCallback onTaped}) {
    return GestureDetector(
      onTap: onTaped,
      child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withAlpha((0.3 * 255).toInt()),
          ),
          child: Icon(icon, color: Colors.white)),
    );
  }

  Widget buildColorOption(Color color, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  Widget buildButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
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
