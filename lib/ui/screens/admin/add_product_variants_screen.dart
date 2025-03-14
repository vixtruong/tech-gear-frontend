import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/models/brand.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/models/variant_option.dart';
import 'package:techgear/models/variant_value.dart';
import 'package:techgear/providers/brand_provider.dart';
import 'package:techgear/providers/category_provider.dart';
import 'package:techgear/providers/product_provider.dart';
import 'package:techgear/providers/variant_option_provider.dart';
import 'package:techgear/providers/variant_value_provider.dart';
import 'package:techgear/ui/widgets/custom_dropdown.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';
import 'package:techgear/ui/widgets/image_picker_field.dart';

class AddProductVariantsScreen extends StatefulWidget {
  final String productId;

  const AddProductVariantsScreen({super.key, required this.productId});

  @override
  State<AddProductVariantsScreen> createState() =>
      _AddProductVariantsScreenState();
}

class _AddProductVariantsScreenState extends State<AddProductVariantsScreen> {
  final ProductProvider _productProvider = ProductProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final BrandProvider _brandProvider = BrandProvider();
  final VariantOptionProvider _variantOptionProvider = VariantOptionProvider();
  final VariantValueProvider _variantValueProvider = VariantValueProvider();

  final List<Category> _categories = [];
  final List<Brand> _brands = [];
  List<VariantOption> _variantOptions = [];
  List<VariantValue> _allVariantValues = [];

  Product? product;

  final _key = GlobalKey<FormState>();

  String? _selectedBrand;
  String? _selectedCategory;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _selectedImage;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      Product? fetchedProduct =
          await _productProvider.fetchProductById(widget.productId);
      Category? category =
          await _categoryProvider.fetchCategoryById(fetchedProduct!.categoryId);

      Brand? brand =
          await _brandProvider.fetchBrandById(fetchedProduct.brandId);

      await _variantOptionProvider.fetchVariantOptionsByCateId(category!.id);
      await _variantValueProvider.fetchVariantValues();

      setState(() {
        product = fetchedProduct;

        _categories.add(category);
        _brands.add(brand!);

        _variantOptions = _variantOptionProvider.variantOptions;
        _allVariantValues = _variantValueProvider.variantValues;
      });
    } catch (e) {}
  }

  void _handleSubmit() async {}

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
          "Add ${product?.name ?? ""} Variant",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
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
                          CustomDropdown(
                            label: "Brands",
                            hint: "Select a brand",
                            value: _brands[0].name,
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
                            value: _categories[0].name,
                            items: _categories
                                .map((category) => category.name)
                                .toList(),
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
                        hint: "SKU",
                        inputType: TextInputType.name,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter SKU";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10, // Khoảng cách giữa các phần tử
                        runSpacing: 15, // Khoảng cách giữa các hàng
                        children:
                            List.generate(_variantOptions.length, (index) {
                          var option = _variantOptions[index];

                          List<VariantValue> variantValues = _allVariantValues
                              .where((x) => x.variantOptionId == option.id)
                              .toList();

                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2 -
                                20, // Chia đôi màn hình
                            child: CustomDropdown(
                              label: option.name,
                              hint: "Select ${option.name} value",
                              items: variantValues.map((x) => x.name).toList(),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        controller: _descriptionController,
                        hint: "Quantity",
                        inputType: TextInputType.number,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter quantity";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        controller: _priceController,
                        hint: "Price",
                        inputType: TextInputType.number,
                        isSearch: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter price";
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
