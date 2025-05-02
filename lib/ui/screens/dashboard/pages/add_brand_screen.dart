import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/product/brand.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({super.key});

  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final _key = GlobalKey<FormState>();

  final TextEditingController _brandController = TextEditingController();

  late BrandProvider _brandProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
  }

  void _handleSubmit() async {
    if (_key.currentState!.validate()) {
      String brandName = _brandController.text.trim();

      if (brandName.isEmpty) return;

      _key.currentState?.save();

      Brand? brand = await _brandProvider.fetchBrandByName(brandName);

      if (brand != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$brandName already exists!",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red[200],
          ),
        );
        return;
      }

      await _brandProvider.addBrand(brandName);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$brandName added successfully!",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        title: const Text(
          "Add Brand",
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
                controller: _brandController,
                hint: "Name",
                inputType: TextInputType.text,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter brand name";
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
