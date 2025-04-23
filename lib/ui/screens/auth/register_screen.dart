import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/register_request_dto.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/order_providers/cart_provider.dart';
import 'package:techgear/ui/widgets/common/custom_button.dart';
import '../../widgets/common/custom_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late AuthProvider _authProvider;
  late SessionProvider _sessionProvider;
  late CartProvider _cartProvider;

  final _key = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
  }

  Future<void> _submidRegister() async {
    if (!_key.currentState!.validate()) return;

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (fullName.isEmpty ||
        email.isEmpty ||
        !emailRegex.hasMatch(email) ||
        phoneNumber.isEmpty ||
        phoneNumber.length != 10 ||
        address.isEmpty ||
        password.isEmpty ||
        password.length < 8 ||
        password.length > 24 ||
        confirmPassword != password) {
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

      final registerRequest = RegisterRequestDto(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        role: "Customer",
        address: address,
      );

      final data = await _authProvider.register(registerRequest);

      if (data == null) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'User already exists. Please change information or login'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      var loginResponse = await _authProvider.login(email, password);
      if (loginResponse == null) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed after registration. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _sessionProvider.saveSession(
          loginResponse['accessToken'], loginResponse['refreshToken']);
      await _sessionProvider.loadSession();

      await _cartProvider.updateCartToServer();
      if (mounted) {
        Navigator.of(context).pop();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
                      "assets/images/register.png",
                      width: wide ? 150 : 200,
                      height: wide ? 150 : 200,
                    ),
                    const SizedBox(height: 15),
                    _buildTitleText(),
                    const SizedBox(height: 30),
                    CustomInputField(
                      controller: _fullNameController,
                      icon: Icons.person,
                      hintText: "Full name",
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter full name";
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                      controller: _phoneController,
                      icon: Icons.phone,
                      hintText: "Phone number",
                      keyboardType: TextInputType.phone,
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
                    const SizedBox(height: 15),
                    CustomInputField(
                      controller: _addressController,
                      icon: Icons.location_on,
                      hintText: "Delivery address",
                      keyboardType: TextInputType.streetAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter delivery address";
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
                      hintText: "Confirm Password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        final checkPassword = _passwordController.text.trim();

                        if (value != checkPassword) {
                          return "Confirm password not match password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: "Register",
                      onPressed: () {
                        _submidRegister();
                      },
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => context.pop(),
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
                    const SizedBox(height: 15),
                    const Text(
                      "OR",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      text: "Continue as Guest",
                      onPressed: () {
                        context.push('/home');
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
          "Register your account",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Fill in your details to create a new account",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
