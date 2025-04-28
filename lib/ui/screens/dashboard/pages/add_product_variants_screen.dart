import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/brand.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/models/product/product.dart';
import 'package:techgear/models/product/product_config.dart';
import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/models/product/variant_option.dart';
import 'package:techgear/models/product/variant_value.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_config_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';
import 'package:techgear/ui/widgets/image/image_picker_field.dart';

class AddProductVariantsScreen extends StatefulWidget {
  final String productId;

  const AddProductVariantsScreen({super.key, required this.productId});

  @override
  State<AddProductVariantsScreen> createState() =>
      _AddProductVariantsScreenState();
}

class _AddProductVariantsScreenState extends State<AddProductVariantsScreen> {
  late ProductProvider _productProvider;
  late ProductItemProvider _productItemProvider;
  late CategoryProvider _categoryProvider;
  late BrandProvider _brandProvider;
  late VariantOptionProvider _variantOptionProvider;
  late VariantValueProvider _variantValueProvider;
  late ProductConfigProvider _productConfigProvider;

  List<VariantOption> _variantOptions = [];
  List<VariantValue> _allVariantValues = [];

  Product? product;
  Category? category;
  Brand? brand;

  final _key = GlobalKey<FormState>();

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _selectVariantValueIds = [];

  XFile? _selectedImage;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _productItemProvider =
        Provider.of<ProductItemProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _variantOptionProvider =
        Provider.of<VariantOptionProvider>(context, listen: false);
    _variantValueProvider =
        Provider.of<VariantValueProvider>(context, listen: false);
    _productConfigProvider =
        Provider.of<ProductConfigProvider>(context, listen: false);

    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      Product? fetchedProduct =
          await _productProvider.fetchProductById(widget.productId);
      if (fetchedProduct == null) {
        throw Exception("Product not found");
      }

      Category? fetchedCategory =
          await _categoryProvider.fetchCategoryById(fetchedProduct.categoryId);
      Brand? fetchedBrand =
          await _brandProvider.fetchBrandById(fetchedProduct.brandId);

      await _variantOptionProvider
          .fetchVariantOptionsByCateId(fetchedCategory!.id);
      await _variantValueProvider.fetchVariantValues();

      if (mounted) {
        setState(() {
          product = fetchedProduct;
          category = fetchedCategory;
          brand = fetchedBrand;

          _brandController.text = brand?.name ?? '';
          _categoryController.text = category?.name ?? '';

          _variantOptions = _variantOptionProvider.variantOptions;
          _allVariantValues = _variantValueProvider.variantValues;

          for (int i = 0; i < _variantOptions.length; i++) {
            _selectVariantValueIds.add('');
          }

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

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an image"),
          backgroundColor: Colors.red[200],
        ),
      );
      return;
    }

    for (int i = 0; i < _selectVariantValueIds.length; i++) {
      if (_selectVariantValueIds[i].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Please select a value for ${_variantOptions[i].name}"),
            backgroundColor: Colors.red[200],
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String sku = _nameController.text.trim();
      int quantity = int.parse(_quantityController.text.trim());
      double price = double.parse(_priceController.text.trim());

      ProductItem productItem = ProductItem(
        sku: sku,
        imgFile: _selectedImage!,
        quantity: quantity,
        price: price,
        productId: product!.id,
      );

      ProductItem? newItem =
          await _productItemProvider.addProductItem(productItem);

      List<ProductConfig> configs = [];
      for (int i = 0; i < _variantOptions.length; i++) {
        var config = ProductConfig(
          productItemId: newItem!.id!,
          variantValueId: _selectVariantValueIds[i],
        );
        configs.add(config);
      }

      await _productConfigProvider.addProductConfigs(configs);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${productItem.sku} added successfully!",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
        title: Text(
          "Add ${product?.name ?? "Product"} Variant",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _isLoading
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
                                child: CustomTextField(
                                  controller: _brandController,
                                  hint: "Brand",
                                  inputType: TextInputType.text,
                                  isSearch: false,
                                  enabled: false,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomTextField(
                                  controller: _categoryController,
                                  hint: "Category",
                                  inputType: TextInputType.text,
                                  isSearch: false,
                                  enabled: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: _nameController,
                            hint: "SKU",
                            inputType: TextInputType.name,
                            isSearch: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter SKU";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 10,
                            runSpacing: 15,
                            children:
                                List.generate(_variantOptions.length, (index) {
                              var option = _variantOptions[index];

                              List<VariantValue> variantValues =
                                  _allVariantValues
                                      .where(
                                          (x) => x.variantOptionId == option.id)
                                      .toList();

                              bool isLastOdd =
                                  _variantOptions.length % 2 != 0 &&
                                      index == _variantOptions.length - 1;

                              return SizedBox(
                                width: isLastOdd
                                    ? double.infinity
                                    : (Responsive.isDesktop(context)
                                        ? ((MediaQuery.of(context).size.width *
                                                    5 /
                                                    6) /
                                                2) -
                                            20
                                        : MediaQuery.of(context).size.width /
                                                2 -
                                            20),
                                child: CustomDropdown(
                                  label: option.name,
                                  hint: "Select ${option.name} value",
                                  items: variantValues.isNotEmpty
                                      ? variantValues
                                          .map((x) =>
                                              {'id': x.id, 'name': x.name})
                                          .toList()
                                      : [
                                          {
                                            'id': '',
                                            'name': 'No values available'
                                          }
                                        ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please choose ${option.name}";
                                    }
                                    if (value == '' && variantValues.isEmpty) {
                                      return "No ${option.name} values available";
                                    }
                                    return null;
                                  },
                                  onChanged: variantValues.isNotEmpty
                                      ? (value) {
                                          setState(() {
                                            _selectVariantValueIds[index] =
                                                value!;
                                          });
                                        }
                                      : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: _quantityController,
                            hint: "Quantity",
                            inputType: TextInputType.number,
                            isSearch: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter quantity";
                              }
                              if (int.tryParse(value) == null) {
                                return "Please enter a valid number";
                              }
                              if (int.parse(value) <= 0) {
                                return "Quantity must be greater than 0";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: _priceController,
                            hint: "Price",
                            inputType: TextInputType.number,
                            isSearch: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
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
                            onPressed: _isSubmitting ? null : _handleSubmit,
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
          if (_isSubmitting)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _categoryController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
