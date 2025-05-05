import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/providers/user_provider/favorite_provider.dart';
import 'package:techgear/ui/widgets/product/product_card.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late SessionProvider _sessionProvider;
  late FavoriteProvider _favoriteProvider;
  late ProductProvider _productProvider;

  List<Product> _favoriteProducts = [];

  String? userId;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _sessionProvider.loadSession();

      final fetchUserId = _sessionProvider.userId;

      if (fetchUserId != null) {
        setState(() {
          userId = fetchUserId;
        });

        await _favoriteProvider.fetchFavorites(userId!);
        final fetchFavoritesData = _favoriteProvider.favorites;

        final productIds = fetchFavoritesData;

        await _productProvider.fetchProductsByIds(productIds);

        setState(() {
          _favoriteProducts = _productProvider.productByIds;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: kIsWeb ? 1 : 0,
        title: Text(
          "Wish List",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: userId == null && !_isLoading
          ? Center(
              child: Container(
                color: Colors.grey[50],
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "You are not logged in.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _buildProductList(_favoriteProducts),
                ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text("No products in wishlist"));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 800;
    final itemsPerRow = isWeb ? 5.2 : 2;
    final totalSpacing = (itemsPerRow - 1) * 10;
    final availableWidth = isWeb
        ? (screenWidth >= 1200 ? 1200 : screenWidth - 40)
        : screenWidth - 30;
    final cardWidth = (availableWidth - totalSpacing) / itemsPerRow;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 15,
        children: List.generate(products.length, (index) {
          return SizedBox(
            width: cardWidth,
            child: ProductCard(
              product: products[index],
              atHome: true,
            ),
          );
        }),
      ),
    );
  }
}
