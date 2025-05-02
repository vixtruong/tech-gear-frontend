import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/order_providers/cart_provider.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import '../../widgets/common/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthProvider _authProvider;
  late SessionProvider _sessionProvider;
  late CartProvider _cartProvider;

  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
  }

  Future<void> _submitLogin() async {
    if (!_key.currentState!.validate()) return;

    final checkEmail = _emailController.text.trim();
    final checkPassword = _passwordController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (checkEmail.isEmpty ||
        !emailRegex.hasMatch(checkEmail) ||
        checkPassword.isEmpty) {
      return;
    }

    try {
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

      final loginResponse =
          await _authProvider.login(checkEmail, checkPassword);
      if (loginResponse == null) {
        if (mounted) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login fail. Please check your login information.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await _sessionProvider.saveSession(
          loginResponse['accessToken'], loginResponse['refreshToken']);
      await _sessionProvider.loadSession();

      final userRole = _sessionProvider.role;

      if (userRole != null) {
        if (userRole == "Customer") {
          await _cartProvider.updateCartToServer();

          if (mounted) {
            Navigator.of(context).pop();

            SchedulerBinding.instance.addPostFrameCallback((_) {
              context.go('/home');
            });
          }
        } else {
          if (mounted) {
            Navigator.of(context).pop();

            SchedulerBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login fail. Please check your login information.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;

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
              child: Form(
                key: _key,
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
                    CustomInputField(
                      controller: _emailController,
                      icon: Icons.email,
                      hintText: "Email address",
                      keyboardType: TextInputType.emailAddress,
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
                      hintText: "Password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter password";
                        }
                        return null;
                      },
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
                      onPressed: () {
                        _submitLogin();
                      },
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
