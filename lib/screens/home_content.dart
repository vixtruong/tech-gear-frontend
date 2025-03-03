import 'package:flutter/material.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/widgets/custom_dropdown.dart';
import 'package:techgear/widgets/product_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                onChanged: (value) {},
                decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomDropdown(
                  label: "Sort by",
                  items: ["Name", "Best Selling"],
                  onChanged: (value) {},
                ),
                const SizedBox(width: 5),
                CustomDropdown(
                  label: "Categories",
                  items: ["T Shirt", "Jeans"],
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPriceFilter("Under \$50"),
                _buildPriceFilter("\$50 - \$100"),
                _buildPriceFilter("\$100 - \$200"),
                _buildPriceFilter("Above \$200"),
              ],
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: Product(
                    name: "Product $index",
                    colors: 5,
                    price: 300,
                    rating: 100,
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
          ],
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
