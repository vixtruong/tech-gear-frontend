import 'dart:io';

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
import 'package:techgear/ui/widgets/image_picker_field.dart';

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

  String? _selectedBrand;
  String? _selectedCategory;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  // final TextEditingController _imgController = TextEditingController();

  File? _selectedImage;

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
      await _categoryProvider.fetchCategories();
      await _brandProvider.fetchBrands();
      setState(() {
        _categories = _categoryProvider.categories;
        _brands = _brandProvider.brands;
      });
    } catch (e) {}
  }

  void _handleSubmit() async {
    if (!_key.currentState!.validate()) return;

    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    double price = double.parse(_priceController.text.trim());

    if (name.isEmpty || description.isEmpty || price.toString().isEmpty) {
      return;
    }

    _key.currentState!.save();

    String? categoryId;
    String? brandId;

    for (var item in _categories) {
      if (item.name == _selectedCategory) {
        categoryId = item.id;
        break;
      }
    }

    for (var item in _brands) {
      if (item.name == _selectedBrand) {
        brandId = item.id;
        break;
      }
    }

    Product product = Product(
      name: name,
      price: price,
      description: description,
      brandId: brandId!,
      categoryId: categoryId!,
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
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add product: $e",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    }
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
        title: const Text(
          "Add Product",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                      onChanged: (value) =>
                          setState(() => _selectedBrand = value),
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
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                  ],
                ),
                SizedBox(height: 15),
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
                SizedBox(height: 15),
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
                SizedBox(height: 15),
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
                SizedBox(height: 15),
                // CustomTextField(
                //     controller: _imgController,
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return "Please enter image url";
                //       }
                //       return null;
                //     },
                //     hint: "Image Url",
                //     inputType: TextInputType.url,
                //     isSearch: false),
                // SizedBox(height: 15),
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
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
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
}
