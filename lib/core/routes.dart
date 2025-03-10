import 'package:go_router/go_router.dart';
import 'package:techgear/ui/screens/admin/add_brand_screen.dart';
import 'package:techgear/ui/screens/admin/add_category_screen.dart';
import 'package:techgear/ui/screens/admin/add_product_screen.dart';
import 'package:techgear/ui/screens/user/cart_screen.dart';
import 'package:techgear/ui/screens/user/wish_screen.dart';
import 'package:techgear/ui/screens/user/home_screen.dart';
import 'package:techgear/ui/screens/auth/login_screen.dart';
import 'package:techgear/ui/screens/user/product_detail_screen.dart';
import 'package:techgear/ui/screens/auth/recover_password_screen.dart';
import 'package:techgear/ui/screens/auth/register_screen.dart';
import 'package:techgear/ui/screens/auth/welcome_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/add-product',
  routes: [
    // auth screens
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

    // user screens
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
    GoRoute(
      path: '/product-detail/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishScreen(),
    ),

    // admin screens
    GoRoute(
      path: '/add-brand',
      builder: (context, state) => AddBrandScreen(),
    ),
    GoRoute(
      path: '/add-category',
      builder: (context, state) => AddCategoryScreen(),
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductScreen(),
    ),
  ],
);
