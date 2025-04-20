import 'package:flutter/material.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import '../../widgets/common/custom_input_field.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  bool get isWideScreen => MediaQuery.of(context).size.width > 800;

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen;

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
                  const CustomInputField(
                    icon: Icons.email,
                    hintText: "Email address",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  const CustomInputField(
                    icon: Icons.lock,
                    hintText: "New password",
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  const CustomInputField(
                    icon: Icons.password,
                    hintText: "Confirm password",
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  const CustomInputField(
                    icon: Icons.lock_outline,
                    hintText: "OTP",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Send OTP",
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: "Confirm",
                    onPressed: () {},
                    color: Colors.blue,
                  ),
                ],
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
