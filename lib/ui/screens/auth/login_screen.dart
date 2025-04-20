import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import '../../widgets/common/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              constraints: BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24.0),
              decoration: wide
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
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
                    "assets/images/login.png",
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
                    hintText: "Password",
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (kIsWeb) {
                          context.go('/recover-password');
                        } else {
                          context.push('/recover-password');
                        }
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
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
                          if (kIsWeb) {
                            context.go('/register');
                          } else {
                            context.push('/register');
                          }
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
                  CustomButton(
                    text: "Continue as Guest",
                    onPressed: () {
                      if (kIsWeb) {
                        context.go('/home');
                      } else {
                        context.push('/home');
                      }
                    },
                    color: Colors.grey[700]!,
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
