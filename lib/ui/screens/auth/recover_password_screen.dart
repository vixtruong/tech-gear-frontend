import 'package:flutter/material.dart';
import 'package:techgear/ui/widgets/login_button.dart';
import '../../widgets/custom_input_field.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/reset_password.png",
                  width: 200,
                  height: 200,
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
                  hintText: "Password",
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.password,
                  hintText: "Confirm Password",
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.lock_outline,
                  hintText: "OTP",
                  keyboardType: TextInputType.visiblePassword,
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
                LoginButton(
                  text: "Confirm",
                  onPressed: () {},
                  color: Colors.blue,
                ),
              ],
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
          "Reset password",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        // SizedBox(height: 8),
        // Text(
        //   "Enter your login details to access your account",
        //   textAlign: TextAlign.center,
        //   style: TextStyle(fontSize: 14, color: Colors.black54),
        // ),
      ],
    );
  }
}
