import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/category.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  late CategoryProvider _categoryProvider;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
  }

  void _handleSubmit() async {
    if (!_key.currentState!.validate()) return;

    String categoryName = _categoryController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      Category? existingCategory =
          await _categoryProvider.fetchCategoryByName(categoryName);

      if (!mounted) return;

      if (existingCategory != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$categoryName already exists!",
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red[200],
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _categoryProvider.addCategory(categoryName);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$categoryName added successfully!",
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
          content: Text(
            "Failed to add $categoryName: $e",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        title: const Text(
          "Add Category",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
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
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter category name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
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
          if (_isLoading)
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
    _categoryController.dispose();
    super.dispose();
  }
}
