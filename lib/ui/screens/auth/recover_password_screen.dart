import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import '../../widgets/common/custom_input_field.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  late AuthProvider _authProvider;

  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSendOtp = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email) || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(email.isEmpty
              ? 'Please enter email'
              : 'Please enter a valid email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await _authProvider.sendOtp(email);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP has been sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isSendOtp = true;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_key.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final otp = _otpController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email) ||
        email.isEmpty ||
        password.length < 8 ||
        password.length > 24 ||
        password.isEmpty ||
        confirmPassword != password ||
        confirmPassword.isEmpty ||
        otp.isEmpty ||
        otp.length != 6) {
      return;
    }

    final success = await _authProvider.resetPassword(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_authProvider.errorMessage ?? 'Failed to reset password'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 30,
              horizontal: wide ? 100 : 10,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24.0),
              decoration: wide
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 5,
                        )
                      ],
                    )
                  : null,
              child: Form(
                key: _key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/reset_password.png",
                      width: wide ? 150 : 200,
                      height: wide ? 150 : 200,
                    ),
                    const SizedBox(height: 15),
                    _buildTitleText(),
                    const SizedBox(height: 30),
                    CustomInputField(
                      controller: _emailController,
                      icon: Icons.email,
                      hintText: "Email address",
                      keyboardType: TextInputType.emailAddress,
                      disabled: _isSendOtp,
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
                    const SizedBox(height: 15),
                    CustomInputField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hintText: "New password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter password";
                        }

                        if (value.length < 8 || value.length > 24) {
                          return "Password must be between 8 and 24 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomInputField(
                      controller: _confirmPasswordController,
                      icon: Icons.password,
                      hintText: "Confirm password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        final checkPassword = _passwordController.text.trim();
                        if (value == null || value.isEmpty) {
                          return "Please enter confirm password";
                        }

                        if (value != checkPassword) {
                          return "Confirm password not match password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomInputField(
                      controller: _otpController,
                      icon: Icons.lock_outline,
                      hintText: "OTP",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter OTP code";
                        }

                        if (value.length != 6) {
                          return "OTP must be 6 digits";
                        }

                        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return "OTP must contain only numbers";
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _sendOTP();
                        },
                        child: const Text(
                          "Send OTP",
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: "Confirm",
                      onPressed: () {
                        _handleSubmit();
                      },
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    return const Column(
      children: [
        Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Enter your email and new password to reset your account",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
