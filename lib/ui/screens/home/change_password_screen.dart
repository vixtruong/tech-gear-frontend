import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/change_password_dto.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late AuthProvider _authProvider;
  late SessionProvider _sessionProvider;

  final _key = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    try {
      if (!_key.currentState!.validate()) return;

      final password = _passwordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (password.isEmpty ||
          newPassword.isEmpty ||
          newPassword.length < 8 ||
          newPassword.length > 24 ||
          confirmPassword != newPassword) {
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

      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;

      final dto = ChangePasswordDto(
          userId: int.parse(userId!),
          oldPassword: password,
          newPassword: newPassword,
          confirmPassword: confirmPassword);

      var success = await _authProvider.changePassword(dto);

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change password successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_authProvider.errorMessage ?? 'Failed to change password'),
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
        elevation: kIsWeb ? 1 : 0,
        title: Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Form(
          key: _key,
          child: Column(
            spacing: 10,
            children: [
              CustomTextField(
                controller: _passwordController,
                hint: "Old Password",
                inputType: TextInputType.visiblePassword,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter old password";
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _newPasswordController,
                hint: "New Password",
                inputType: TextInputType.visiblePassword,
                isSearch: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please new password";
                  }

                  if (value.length < 8 || value.length > 24) {
                    return "Password must be between 8 and 24 characters";
                  }

                  return null;
                },
              ),
              CustomTextField(
                controller: _confirmPasswordController,
                hint: "Confirm Password",
                inputType: TextInputType.visiblePassword,
                isSearch: false,
                validator: (value) {
                  final checkPassword = _newPasswordController.text.trim();

                  if (value != checkPassword) {
                    return "Confirm password not match new password";
                  }
                  return null;
                },
              ),
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
