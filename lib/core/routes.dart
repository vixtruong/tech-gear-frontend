import 'package:go_router/go_router.dart';
import 'package:techgear/ui/screens/cart_screen.dart';
import 'package:techgear/ui/screens/home_screen.dart';
import 'package:techgear/ui/screens/login_screen.dart';
import 'package:techgear/ui/screens/recover_password_screen.dart';
import 'package:techgear/ui/screens/register_screen.dart';
import 'package:techgear/ui/screens/welcome_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/recover-password',
      builder: (context, state) => const RecoverPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    // GoRoute(
    //   path: '/profile/:userId',
    //   builder: (context, state) {
    //     final String userId = state.pathParameters['userId']!;
    //     return ProfileScreen(userId: userId);
    //   },
    // ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
  ],
);
