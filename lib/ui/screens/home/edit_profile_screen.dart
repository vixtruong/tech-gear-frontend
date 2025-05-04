import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/edit_profile_dto.dart';
import 'package:techgear/dtos/user_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserProvider _userProvider;
  late SessionProvider _sessionProvider;

  final _key = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  UserDto? user;

  String? fullName;
  String? email;
  String? phoneNumber;

  bool _isLoading = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;

      if (userId != null) {
        final fetchUser = await _userProvider.fetchUser(int.parse(userId));

        setState(() {
          user = fetchUser;
          fullName = user!.fullName;
          email = user!.email;
          phoneNumber = user!.phoneNumber;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      e.toString();
    }
  }

  Future<void> _handleSubmit() async {
    try {
      if (!_key.currentState!.validate()) return;

      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phoneNumber = _phoneController.text.trim();

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (fullName.isEmpty ||
          email.isEmpty ||
          !emailRegex.hasMatch(email) ||
          phoneNumber.isEmpty ||
          phoneNumber.length != 10) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        // ignore: deprecated_member_use
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );

      final dto = EditProfileDto(
          id: user!.id,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber);

      final success = await _userProvider.updateUserInfo(dto);

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pop();
        context.go('/profile');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit profile successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to edit profile. Please check information.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _key,
                child: Column(
                  spacing: 20,
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      enabled: false,
                      hint: "Email",
                      inputType: TextInputType.emailAddress,
                      isSearch: false,
                      value: email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }

                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                        if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: _fullNameController,
                      hint: "Full Name",
                      inputType: TextInputType.text,
                      isSearch: false,
                      value: fullName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter full name";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: _phoneController,
                      hint: "Phone Number",
                      inputType: TextInputType.text,
                      isSearch: false,
                      value: phoneNumber,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter phone number";
                        }
                        if (value.length != 10) {
                          return "Password must has 10 numbers";
                        }

                        return null;
                      },
                    ),
                    CustomButton(
                      text: "Submit",
                      onPressed: _handleSubmit,
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
