import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/models/product/variant_option.dart';
import 'package:techgear/models/product/variant_value.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';
import 'package:techgear/ui/widgets/common/custom_dropdown.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

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
  List<VariantValue> allVariantValues = [];

  String? _selectedCategory;

  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isAddingValue = false;

  // Map to group VariantOption by Category
  final Map<String, List<VariantOption>> _groupedVariantOptions = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _variantOptionProvider =
        Provider.of<VariantOptionProvider>(context, listen: false);
    _variantValueProvider =
        Provider.of<VariantValueProvider>(context, listen: false);

    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _categoryProvider.fetchCategories();
      await _variantOptionProvider.fetchVariantOptions();
      await _variantValueProvider.fetchVariantValues();

      if (mounted) {
        setState(() {
          categories = _categoryProvider.categories;
          variantOptions = _variantOptionProvider.variantOptions;
          allVariantValues = _variantValueProvider.variantValues;
          _groupVariantOptions(); // Group VariantOption by Category
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

  // Function to group VariantOption by Category
  void _groupVariantOptions() {
    _groupedVariantOptions.clear();
    for (var option in variantOptions) {
      if (_selectedCategory == null || option.categoryId == _selectedCategory) {
        _groupedVariantOptions.putIfAbsent(
          option.categoryId,
          () => [],
        );
        _groupedVariantOptions[option.categoryId]!.add(option);
      }
    }
  }

  Future<void> _deleteVariantValue(String id) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _variantValueProvider.deleteVariantValue(id);

      if (mounted) {
        setState(() {
          allVariantValues = _variantValueProvider.variantValues;
          _groupVariantOptions(); // Re-group after deletion
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Variant value deleted successfully!",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green[400],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        animatedIcon: AnimatedIcons.menu_close,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        elevation: 10.0,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_circle, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Add Variation',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              if (kIsWeb) {
                context.go('/add-variant-option');
              } else {
                context.push('/add-variant-option');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Container(
              color: Colors.grey[50],
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _variantOptionProvider
                          .filterByCategory(_selectedCategory);
                      await _loadInformation();
                    },
                    backgroundColor: Colors.white,
                    color: Colors.blue,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomDropdown(
                                  label: "Categories",
                                  items: categories
                                      .map((cate) =>
                                          {'id': cate.id, 'name': cate.name})
                                      .toList(),
                                  value: _selectedCategory,
                                  hint: "Select a category",
                                  validator: (value) {
                                    return null; // Optional validation
                                  },
                                  onChanged: _isLoading ||
                                          _isDeleting ||
                                          _isAddingValue
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _selectedCategory = value;
                                            _variantOptionProvider
                                                .filterByCategory(
                                                    _selectedCategory);
                                            variantOptions =
                                                _variantOptionProvider
                                                    .variantOptions;
                                            _groupVariantOptions();
                                          });
                                        },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                )
                              : _buildGroupedVariantOptions(),
                        ],
                      ),
                    ),
                  ),
                  if (_isDeleting || _isAddingValue)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // Widget to display VariantOption grouped by Category
  Widget _buildGroupedVariantOptions() {
    if (_groupedVariantOptions.isEmpty) {
      return Center(
        child: Text(
          "No variant options available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _groupedVariantOptions.keys.length,
      itemBuilder: (context, index) {
        String categoryId = _groupedVariantOptions.keys.elementAt(index);
        List<VariantOption> options = _groupedVariantOptions[categoryId]!;
        Category? category =
            categories.firstWhere((cate) => cate.id == categoryId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            ...options.map((option) {
              List<VariantValue> variantValues = allVariantValues
                  .where((x) => x.variantOptionId == option.id)
                  .toList();
              return _buildVariantsValues(
                  option.name, option.id, variantValues);
            }),
            SizedBox(height: 15),
          ],
        );
      },
    );
  }

  Widget _buildVariantsValues(String name, String id, List<VariantValue> list) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              name,
              style: const TextStyle(
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
                  if (value == 'add-value') {
                    _showAddValueDialog(context, id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add-value',
                    child: Text('Add value'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                icon: const Icon(Icons.more_vert_outlined),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildListTile(list[index].name, list[index].id);
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildListTile(String name, String id) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: SizedBox(
        width: 30,
        height: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          color: Colors.white,
          iconSize: 18,
          onSelected: (value) {
            if (value == 'delete') {
              _deleteVariantValue(id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Text('Rename'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          icon: const Icon(Icons.more_vert_outlined),
          position: PopupMenuPosition.under,
        ),
      ),
    );
  }

  void _showAddValueDialog(BuildContext context, String variantOptionId) {
    final TextEditingController controller = TextEditingController();

    void submitAddOptionValue() async {
      String value = controller.text.trim();

      if (value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please enter a value",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red[200],
          ),
        );
        return;
      }

      var variantValue =
          VariantValue(name: value, variantOptionId: variantOptionId);

      setState(() {
        _isAddingValue = true;
      });

      try {
        var existValue =
            await _variantValueProvider.fetchVariantValueByName(value);
        if (existValue != null &&
            existValue.variantOptionId == variantValue.variantOptionId) {
          if (!mounted) return;
          if (mounted) {
            // ignore: use_build_context_synchronously
            context.pop();
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Variant value already exists!",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Colors.red[200],
              ),
            );
          }
          return;
        }

        await _variantValueProvider.addVariantValue(variantValue);
        if (mounted) {
          // ignore: use_build_context_synchronously
          context.pop();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Value ${variantValue.name} added successfully!",
                style: const TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.green[400],
            ),
          );
          setState(() {
            allVariantValues.add(variantValue);
            _groupVariantOptions(); // Re-group after adding
          });
        }
      } catch (e) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          context.pop();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isAddingValue = false;
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Enter Value"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: CustomTextField(
              controller: controller,
              hint: "Enter value",
              inputType: TextInputType.text,
              isSearch: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter a value";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isAddingValue ? null : () => context.pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: _isAddingValue ? null : submitAddOptionValue,
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }
}
