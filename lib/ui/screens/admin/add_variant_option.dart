import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/models/variant_option.dart';
import 'package:techgear/providers/category_provider.dart';
import 'package:techgear/providers/variant_option_provider.dart';
import 'package:techgear/ui/widgets/custom_dropdown.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';

class AddVariantOption extends StatefulWidget {
  const AddVariantOption({super.key});

  @override
  State<AddVariantOption> createState() => _AddVariantOptionState();
}

class _AddVariantOptionState extends State<AddVariantOption> {
  late CategoryProvider _categoryProvider;
  late VariantOptionProvider _variantOptionProvider;

  final TextEditingController _controller = TextEditingController();

  List<Category> categories = [];

  String? _selectCatgory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _variantOptionProvider =
        Provider.of<VariantOptionProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    _loadInfomation();
  }

  Future<void> _loadInfomation() async {
    try {
      await _categoryProvider.fetchCategories();
      setState(() {
        categories = _categoryProvider.categories;
      });
    } catch (e) {}
  }

  void _handleSubmit() async {
    String? varName = _controller.text.trim();
    String? cateId;

    for (var cate in categories) {
      if (cate.name == _selectCatgory) {
        cateId = cate.id;
        break;
      }
    }

    var variantOption = VariantOption(
      name: varName,
      categoryId: cateId!,
    );

    try {
      var option = await _variantOptionProvider
          .fetchVariantOptionByName(variantOption.name);
      if (option != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Variant option already exists!",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red[200],
          ),
        );
        return;
      }

      await _variantOptionProvider.addVariantOption(variantOption);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${variantOption.name} added successfully!",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
      context.pop();
    } catch (e) {}
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
        title: Text(
          "Add Variant Option",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomDropdown(
                  label: "Categories",
                  hint: "Select a category",
                  items: categories.map((category) => category.name).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please choose category";
                    }
                    return null;
                  },
                  onChanged: (value) => {
                    setState(() {
                      _selectCatgory = value;
                    })
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: _controller,
              hint: "Variant Option",
              inputType: TextInputType.text,
              isSearch: false,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
