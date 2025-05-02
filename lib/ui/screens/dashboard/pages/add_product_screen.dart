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
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
import 'package:techgear/ui/widgets/image/image_picker_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;
  late BrandProvider _brandProvider;

  List<Category> _categories = [];
  List<Brand> _brands = [];

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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _categoryProvider.fetchCategories();
      await _brandProvider.fetchBrands();
      if (mounted) {
        setState(() {
          _categories = _categoryProvider.categories;
          _brands = _brandProvider.brands;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red[400],
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSubmit() async {
    if (!_key.currentState!.validate()) return;

    if (_selectedBrandId == null ||
        _selectedCategoryId == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a brand, category, and image"),
          backgroundColor: Colors.red[200],
        ),
      );
      return;
    }

    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    double price = double.parse(_priceController.text.trim());

    _key.currentState!.save();

    Product product = Product(
      name: name,
      price: price,
      description: description,
      brandId: _selectedBrandId!,
      categoryId: _selectedCategoryId!,
      imgFile: _selectedImage!,
      imgUrl: "",
    );

    try {
      await _productProvider.addProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${product.name} added successfully!",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );

      if (kIsWeb) {
        context.go('/manage-product');
      } else {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add product: $e",
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
      backgroundColor: Colors.grey[100],
      // appBar: AppBar(
      //   surfaceTintColor: Colors.white,
      //   backgroundColor: Colors.white,
      //   shadowColor: Colors.white,
      //   title: const Text(
      //     "Add Product",
      //     style: TextStyle(fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      // ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
                              items: _brands
                                  .map((brand) =>
                                      {'id': brand.id, 'name': brand.name})
                                  .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
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
                              items: _categories
                                  .map((category) => {
                                        'id': category.id,
                                        'name': category.name
                                      })
                                  .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
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
                          if (value == null) {
                            return "Please select an image";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
