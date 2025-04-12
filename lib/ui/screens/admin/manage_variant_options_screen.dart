import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/models/variant_option.dart';
import 'package:techgear/models/variant_value.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';
import 'package:techgear/ui/widgets/custom_dropdown.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';

class ManageVariantOptionsScreen extends StatefulWidget {
  const ManageVariantOptionsScreen({super.key});

  @override
  State<ManageVariantOptionsScreen> createState() =>
      _ManageVariantOptionsScreenState();
}

class _ManageVariantOptionsScreenState
    extends State<ManageVariantOptionsScreen> {
  late CategoryProvider _categoryProvider;
  late VariantOptionProvider _variantOptionProvider;
  late VariantValueProvider _variantValueProvider;

  List<Category> categories = [];
  List<VariantOption> variantOptions = [];
  List<VariantOption> allVariantOptions = [];

  List<VariantValue> allVariantValues = [];

  String? _selectCatgory;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _variantOptionProvider =
        Provider.of<VariantOptionProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _variantValueProvider =
        Provider.of<VariantValueProvider>(context, listen: false);

    _loadInfomation();
  }

  Future<void> _loadInfomation() async {
    try {
      await _categoryProvider.fetchCategories();
      await _variantOptionProvider.fetchVariantOptions();
      await _variantValueProvider.fetchVariantValues();

      setState(() {
        categories = _categoryProvider.categories;

        allVariantValues = _variantValueProvider.variantValues;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red[400]),
        );
      }
    }
  }

  Future<void> _deleteVariantValue(String id) async {
    try {
      await _variantValueProvider.deleteVariantValue(id);

      setState(() {
        allVariantValues = _variantValueProvider.variantValues;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Variant value is deleted successful!",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
    } catch (e) {
      e.toString();
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
          "Manage Variants Options",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/add-variant-option');
            },
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Consumer<VariantOptionProvider>(
        builder: (context, variantOptionProvider, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          variantOptions = _variantOptionProvider.variantOptions;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _selectCatgory = null;
              });
              _variantOptionProvider.filterByCategory(_selectCatgory);
              await Future.delayed(Duration(milliseconds: 500));
            },
            backgroundColor: Colors.white,
            color: Colors.blue,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomDropdown(
                        label: "Categories",
                        items: categories
                            .map((cate) => {'id': cate.id, 'name': cate.name})
                            .toList(),
                        value: _selectCatgory,
                        hint: "Select a category",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please choose category";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectCatgory = value;
                          });

                          _variantOptionProvider
                              .filterByCategory(_selectCatgory);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: variantOptions.length,
                    itemBuilder: (context, index) {
                      var option = variantOptions[index];

                      List<VariantValue> variantValues = [];

                      variantValues = allVariantValues
                          .where((x) => x.variantOptionId == option.id)
                          .toList();

                      return _buildVariantsValues(
                          option.name, option.id, variantValues);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVariantsValues(String name, String id, List<VariantValue> list) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: 30,
              height: 30,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                color: Colors.white,
                onSelected: (value) {
                  // Xử lý khi chọn một mục
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      _showAddValueDialog(context, id);
                    },
                    value: 'add-value',
                    child: Text('Add value'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                icon: Icon(Icons.more_vert_outlined),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildListTile(list[index].name, list[index].id);
            },
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildListTile(String name, String id) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(fontSize: 16),
      ),
      trailing: SizedBox(
        width: 30,
        height: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          color: Colors.white,
          iconSize: 18,
          onSelected: (value) {
            // Xử lý khi chọn một mục
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Text('Rename'),
            ),
            PopupMenuItem(
              onTap: () => _deleteVariantValue(id),
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          icon: Icon(Icons.more_vert_outlined),
          position: PopupMenuPosition.under,
        ),
      ),
    );
  }

  void _showAddValueDialog(BuildContext context, String variantOptionId) async {
    TextEditingController controller = TextEditingController();

    void submitAddOptionValue() async {
      String value = controller.text.trim();

      var variantValue =
          VariantValue(name: value, variantOptionId: variantOptionId);

      try {
        var existValue =
            await _variantValueProvider.fetchVariantValueByName(value);
        if (existValue != null &&
            existValue.variantOptionId == variantValue.variantOptionId) {
          if (!mounted) return;

          if (context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Variant value already exists!",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Colors.red[200],
              ),
            );
            return;
          }
        }

        await _variantValueProvider.addVariantValue(variantValue);
        if (!mounted) return;
        if (context.mounted) {
          context.pop();
          // _loadInfomation();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${variantValue.name} value added successfully!",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.green[400],
            ),
          );

          setState(() {
            allVariantValues.add(variantValue);
          });
        }
      } catch (e) {
        if (!mounted) return;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error: ${e.toString()}"),
                backgroundColor: Colors.red[400]),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Enter Value"),
          content: CustomTextField(
            controller: controller,
            hint: "Enter Value",
            inputType: TextInputType.text,
            isSearch: false,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: submitAddOptionValue,
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (!mounted) {
        controller.dispose();
      }
    });
  }
}
