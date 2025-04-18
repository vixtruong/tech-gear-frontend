import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
import 'package:techgear/ui/widgets/product/product_card.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;

  List<Category> _categories = [];
  List<Product> _products = [];

  final TextEditingController _searchController = TextEditingController();
  final int cartItemCount = 3;
  bool _isLoading = true;

  // Biến để lưu trạng thái bộ lọc
  String? _selectedCategoryId = '';
  String? _selectedPriceRange;
  String? _selectedSortOption = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      await _categoryProvider.fetchCategories();
      await _productProvider.fetchProducts();
      setState(() {
        _categories = _categoryProvider.categories;
        _products = _productProvider.products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  // Hàm hiển thị BottomSheet cho bộ lọc (Mobile)
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thanh kéo để đóng BottomSheet
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tiêu đề
                      const Text(
                        "Filter Options",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sắp xếp
                      const Text(
                        "Sort by",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomDropdown(
                        label: "Sort",
                        items: [
                          {'id': '', 'name': 'Không sắp xếp'},
                          {
                            'id': 'price_low_to_high',
                            'name': 'Giá: Thấp đến Cao'
                          },
                          {
                            'id': 'price_high_to_low',
                            'name': 'Giá: Cao đến Thấp'
                          },
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            _selectedSortOption = value;
                          });
                          setState(() {}); // Cập nhật màn hình chính
                        },
                        value: _selectedSortOption,
                      ),
                      const SizedBox(height: 20),
                      // Danh mục
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomDropdown(
                        label: "Categories",
                        items: [
                          {'id': '', 'name': 'Tất cả danh mục'},
                          ..._categories.map(
                              (cate) => {'id': cate.id, 'name': cate.name}),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            _selectedCategoryId = value;
                          });
                          setState(() {});
                        },
                        value: _selectedCategoryId,
                      ),
                      const SizedBox(height: 20),
                      // Khoảng giá
                      const Text(
                        "Price",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPriceFilterChip(
                            label: "Dưới 2 triệu",
                            value: 'under_2m',
                            updateState: setModalState,
                          ),
                          _buildPriceFilterChip(
                            label: "2 - 5 triệu",
                            value: '2m_5m',
                            updateState: setModalState,
                          ),
                          _buildPriceFilterChip(
                            label: "5 - 10 triệu",
                            value: '5m_10m',
                            updateState: setModalState,
                          ),
                          _buildPriceFilterChip(
                            label: "10 - 20 triệu",
                            value: '10m_20m',
                            updateState: setModalState,
                          ),
                          _buildPriceFilterChip(
                            label: "20 - 30 triệu",
                            value: '20m_30m',
                            updateState: setModalState,
                          ),
                          _buildPriceFilterChip(
                            label: "Trên 30 triệu",
                            value: 'above_30m',
                            updateState: setModalState,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Nút áp dụng
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Cập nhật giao diện chính
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Apply filter",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Hàm xây dựng ChoiceChip cho khoảng giá
  Widget _buildPriceFilterChip({
    required String label,
    required String value,
    required void Function(void Function()) updateState,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: _selectedPriceRange == value ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
      selected: _selectedPriceRange == value,
      selectedColor: Colors.blue[600],
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _selectedPriceRange == value
              ? Colors.blue[600]!
              : Colors.grey[300]!,
        ),
      ),
      onSelected: (selected) {
        updateState(() {
          _selectedPriceRange = selected ? value : null;
        });
        setState(() {}); // Cập nhật màn hình chính
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 800;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: !isWeb
            ? AppBar(
                surfaceTintColor: Colors.white,
                backgroundColor: Colors.white,
                shadowColor: Colors.white,
                leadingWidth: double.infinity,
                leading: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _searchController,
                          hint: "Search...",
                          isSearch: true,
                          inputType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _iconBtn(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                      const SizedBox(width: 10),
                      _iconBtn(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () => _navigate(context, '/wish-list'),
                      ),
                      const SizedBox(width: 10),
                      _iconBtn(
                        icon: badges.Badge(
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.red,
                            padding: EdgeInsets.all(5),
                          ),
                          badgeContent: Text(
                            '$cartItemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                        onPressed: () => _navigate(context, '/cart'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
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

            // Lọc sản phẩm theo danh mục
            List<Category> filteredCategories =
                _selectedCategoryId == null || _selectedCategoryId!.isEmpty
                    ? _categories
                    : _categories
                        .where((cate) => cate.id == _selectedCategoryId)
                        .toList();

            // Lọc sản phẩm theo giá
            List<Product> filteredProducts = _products;
            if (_selectedPriceRange != null) {
              filteredProducts = filteredProducts.where((product) {
                final priceInMillion = product.price / 1000000;
                if (_selectedPriceRange == 'under_2m') {
                  return priceInMillion < 2;
                }
                if (_selectedPriceRange == '2m_5m') {
                  return priceInMillion >= 2 && priceInMillion <= 5;
                }
                if (_selectedPriceRange == '5m_10m') {
                  return priceInMillion > 5 && priceInMillion <= 10;
                }
                if (_selectedPriceRange == '10m_20m') {
                  return priceInMillion > 10 && priceInMillion <= 20;
                }
                if (_selectedPriceRange == '20m_30m') {
                  return priceInMillion > 20 && priceInMillion <= 30;
                }
                if (_selectedPriceRange == 'above_30m') {
                  return priceInMillion > 30;
                }
                return true;
              }).toList();
            }

            // Sắp xếp sản phẩm
            if (_selectedSortOption != null) {
              if (_selectedSortOption == 'price_low_to_high') {
                filteredProducts.sort((a, b) => a.price.compareTo(b.price));
              } else if (_selectedSortOption == 'price_high_to_low') {
                filteredProducts.sort((a, b) => b.price.compareTo(a.price));
              }
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar cho Web
                if (isWeb)
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Filter Options",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sắp xếp
                        const Text(
                          "Sort by",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomDropdown(
                          label: "Sort",
                          items: [
                            {'id': '', 'name': 'Không sắp xếp'},
                            {
                              'id': 'price_low_to_high',
                              'name': 'Giá: Thấp đến Cao'
                            },
                            {
                              'id': 'price_high_to_low',
                              'name': 'Giá: Cao đến Thấp'
                            },
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSortOption = value;
                            });
                          },
                          value: _selectedSortOption,
                        ),
                        const SizedBox(height: 40),
                        // Danh mục
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomDropdown(
                          label: "Categories",
                          items: [
                            {'id': '', 'name': 'Tất cả danh mục'},
                            ..._categories.map(
                              (cate) => {'id': cate.id, 'name': cate.name},
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          value: _selectedCategoryId,
                        ),
                        const SizedBox(height: 40),
                        // Khoảng giá
                        const Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPriceFilterChip(
                              label: "Dưới 2 triệu",
                              value: 'under_2m',
                              updateState: setState,
                            ),
                            _buildPriceFilterChip(
                              label: "2 - 5 triệu",
                              value: '2m_5m',
                              updateState: setState,
                            ),
                            _buildPriceFilterChip(
                              label: "5 - 10 triệu",
                              value: '5m_10m',
                              updateState: setState,
                            ),
                            _buildPriceFilterChip(
                              label: "10 - 20 triệu",
                              value: '10m_20m',
                              updateState: setState,
                            ),
                            _buildPriceFilterChip(
                              label: "20 - 30 triệu",
                              value: '20m_30m',
                              updateState: setState,
                            ),
                            _buildPriceFilterChip(
                              label: "Trên 30 triệu",
                              value: 'above_30m',
                              updateState: setState,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Nội dung chính
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...filteredCategories.map((category) {
                                final categoryProducts = filteredProducts
                                    .where((product) =>
                                        product.categoryId == category.id)
                                    .toList();
                                if (categoryProducts.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      spacing:
                                          10, // Khoảng cách ngang giữa các ProductCard
                                      runSpacing:
                                          15, // Khoảng cách dọc giữa các hàng
                                      children: List.generate(
                                          categoryProducts.length, (index) {
                                        // Tính chiều rộng động dựa trên màn hình
                                        final screenWidth =
                                            MediaQuery.of(context).size.width;
                                        final isWeb = screenWidth >= 800;
                                        final itemsPerRow = isWeb
                                            ? 4.2
                                            : 2; // 4 sản phẩm trên web, 2 trên mobile
                                        final totalSpacing = (itemsPerRow - 1) *
                                            10; // Tổng khoảng cách giữa các sản phẩm
                                        final availableWidth = isWeb
                                            ? (screenWidth >= 1200
                                                ? 1200
                                                : screenWidth -
                                                    40) // Trừ padding nếu cần
                                            : screenWidth -
                                                30; // Trừ padding ngang (15 mỗi bên) trên mobile
                                        final cardWidth =
                                            (availableWidth - totalSpacing) /
                                                itemsPerRow;

                                        return SizedBox(
                                          width:
                                              cardWidth, // Chiều rộng động cho ProductCard
                                          child: ProductCard(
                                            product: categoryProducts[index],
                                            atHome: true,
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 20),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _iconBtn({required Widget icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: IconButton(onPressed: onPressed, icon: icon),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (kIsWeb) {
      context.go(route);
    } else {
      context.push(route);
    }
  }
}
