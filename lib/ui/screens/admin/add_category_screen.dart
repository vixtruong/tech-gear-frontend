import 'package:flutter/material.dart';
import 'package:techgear/models/category.dart';
import 'package:techgear/providers/category_provider.dart';
import 'package:techgear/ui/widgets/custom_text_field.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _key = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();

  final CategoryProvider _categoryProvider = CategoryProvider();

  @override
  void initState() {
    super.initState();
  }

  void _handleSubmit() async {
    if (!_key.currentState!.validate()) return;

    String? categoryName = _categoryController.text.trim();

    if (categoryName.isEmpty) return;

    _key.currentState?.save();

    Category? category =
        await _categoryProvider.fetchCategoryByName(categoryName);

    if (category != null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$categoryName already exists!",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red[200],
        ),
      );

      return;
    }

    try {
      await _categoryProvider.addCategory(categoryName);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$categoryName added successfully!",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Add $categoryName failed!",
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
              // context.pop();
            },
            child: Icon(Icons.arrow_back_outlined)),
        title: const Text(
          "Add Category",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomTextField(
                controller: _categoryController,
                hint: "Name",
                inputType: TextInputType.text,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter category name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
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
    );
  }
}
