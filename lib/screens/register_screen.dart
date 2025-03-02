import 'package:flutter/material.dart';
import 'package:techgear/widgets/login_button.dart';

import '../widgets/custom_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                  "assets/images/register.png",
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 15),
                _buildTitleText(),
                const SizedBox(height: 30),
                const CustomInputField(
                  icon: Icons.person,
                  hintText: "Full name",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.email,
                  hintText: "Email address",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.phone,
                  hintText: "Phone number",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.location_on,
                  hintText: "Delivery address",
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.lock,
                  hintText: "Password",
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 15),
                const CustomInputField(
                  icon: Icons.password,
                  hintText: "Confirm Password",
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 30),
                LoginButton(
                  text: "Register",
                  onPressed: () {},
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("If you have an account, please "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
          "Register account",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        SizedBox(height: 8),
        Text(
          "Enter your information to create new account",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
