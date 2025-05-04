import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/user/user_address.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/user_provider/user_address_provider.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late UserAddressProvider _addressProvider;
  late SessionProvider _sessionProvider;

  final _key = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addressProvider = Provider.of<UserAddressProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  Future<void> _handleSubmit() async {
    try {
      if (!_key.currentState!.validate()) return;

      final address = _addressController.text.trim();
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      if (address.isEmpty ||
          name.isEmpty ||
          phone.isEmpty ||
          phone.length != 10) return;

      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;

      if (userId != null) {
        final dto = UserAddress(
          userId: int.parse(userId),
          address: address,
          recipientName: name,
          recipientPhone: phone,
        );

        await _addressProvider.addAddress(dto);

        if (!_addressProvider.isLoading) {
          if (!mounted) return;

          kIsWeb ? context.go('/addresses') : context.pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New address added successfully.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('AddAddressScreen Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: kIsWeb ? 1 : 0,
        title: const Text(
          "Add Address",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _addressController,
                hint: "Address",
                inputType: TextInputType.text,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _nameController,
                hint: "Recipient Name",
                inputType: TextInputType.text,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter recipient name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _phoneController,
                hint: "Recipient Phone",
                inputType: TextInputType.phone,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter recipient phone";
                  }
                  if (value.length != 10) {
                    return "Phone must be 10 digits";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Submit",
                onPressed: _handleSubmit,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
