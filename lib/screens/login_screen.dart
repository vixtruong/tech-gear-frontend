import 'package:flutter/material.dart';
import 'package:techgear/screens/register_screen.dart';
import 'package:techgear/screens/reset_password_screen.dart';
import 'package:techgear/widgets/login_button.dart';

import '../widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  "assets/images/login.png",
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                LoginButton(
                  text: "Log in",
                  onPressed: () {},
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "OR",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),
                LoginButton(
                  text: "Continue as Guest",
                  onPressed: () {},
                  color: Colors.grey[700]!,
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
          "Log in your account",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        SizedBox(height: 8),
        Text(
          "Enter your login details to access your account",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
