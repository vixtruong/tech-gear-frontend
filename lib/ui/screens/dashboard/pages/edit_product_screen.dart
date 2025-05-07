import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/brand.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/ui/screens/dashboard/pages/manage_coupons_screen.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/image/image_picker_field.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late CategoryProvider _categoryProvider;
  late BrandProvider _brandProvider;
  late ProductProvider _productProvider;

  List<Category> _categories = [];
  List<Brand> _brands = [];

  Product? _product;

  final _key = GlobalKey<FormState>();

  String? _selectedBrandId;
  String? _selectedCategoryId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  XFile? _selectedImage;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _loadInfomation();
  }

  Future<void> _loadInfomation() async {
    try {
      await _categoryProvider.fetchCategories();
      await _brandProvider.fetchBrands();
      final fetchProduct =
          await _productProvider.fetchProductById(widget.productId.toString());

      setState(() {
        _categories = _categoryProvider.categories;
        _brands = _brandProvider.brands;
        _product = fetchProduct;
        _selectedCategoryId = fetchProduct!.categoryId;
        _selectedBrandId = fetchProduct.brandId;
        _nameController.text = fetchProduct.name;
        _descriptionController.text = fetchProduct.description;
        _priceController.text = fetchProduct.price.toString();

        _isLoading = false;
      });
    } catch (e) {
      e.toString();
    }
  }

  void _handleSubmit() async {
    if (!_key.currentState!.validate()) return;

    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    double price = double.parse(_priceController.text.trim());

    if (_selectedBrandId == null ||
        _selectedCategoryId == null ||
        name.isEmpty ||
        description.isEmpty ||
        _priceController.text.trim().isEmpty) {
      return;
    }

    _key.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    Product product = Product(
      id: _product!.id,
      name: name,
      price: price,
      description: description,
      brandId: _selectedBrandId!,
      categoryId: _selectedCategoryId!,
      imgFile: _selectedImage ?? XFile(''),
      imgUrl: _product?.imgUrl ?? '',
    );

    try {
      await _productProvider.updateProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${product.name} updated successfully!",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );

      setState(() {
        _isLoading = false;
      });

      if (kIsWeb) {
        context.pushReplacement('/manage-product');
      } else {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update product: $e",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          _product?.name ?? "Edit Product",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdown(
                              label: "Brands",
                              hint: "Select a brand",
                              value: _selectedBrandId,
                              items: _brands
                                  .map((brand) =>
                                      {'id': brand.id, 'name': brand.name})
                                  .toList(),
                              validator: (value) {
                                if ((value == null || value.isEmpty) &&
                                    _selectedBrandId == null) {
                                  return "Please choose brand";
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  setState(() => _selectedBrandId = value),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomDropdown(
                              label: "Categories",
                              hint: "Select a category",
                              value: _selectedCategoryId,
                              items: _categories
                                  .map((category) => {
                                        'id': category.id,
                                        'name': category.name
                                      })
                                  .toList(),
                              validator: (value) {
                                if ((value == null || value.isEmpty) &&
                                    _selectedCategoryId == null) {
                                  return "Please choose category";
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  setState(() => _selectedCategoryId = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _nameController,
                        hint: "Name",
                        inputType: TextInputType.name,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _descriptionController,
                        hint: "Description",
                        inputType: TextInputType.text,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter description";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _priceController,
                        hint: "Base Price",
                        inputType: TextInputType.number,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter base price";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number";
                          }
                          if (double.parse(value) <= 0) {
                            return "Price must be greater than 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      ImagePickerField(
                        label: "Product Image",
                        onImagePicked: (value) {
                          setState(() {
                            _selectedImage = value;
                          });
                        },
                        validator: (value) {
                          if (_selectedImage == null &&
                              _product?.imgUrl == '') {
                            return "Please select an image";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      if (_selectedImage == null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Image.network(_product!.imgUrl,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      if (_selectedImage == null) const SizedBox(height: 15),
                      CustomButton(
                        text: "Submit",
                        onPressed: _handleSubmit,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
