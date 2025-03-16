import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/ui/screens/admin/add_brand_screen.dart';
import 'package:techgear/ui/screens/admin/add_category_screen.dart';
import 'package:techgear/ui/screens/admin/add_product_screen.dart';
import 'package:techgear/ui/screens/admin/add_product_variants_screen.dart';
import 'package:techgear/ui/screens/admin/add_variant_option_screen.dart';
import 'package:techgear/ui/screens/admin/manage_product_screen.dart';
import 'package:techgear/ui/screens/admin/manage_variant_options_screen.dart';
import 'package:techgear/ui/screens/admin/manage_product_variants_screen.dart';
import 'package:techgear/ui/screens/user/cart_screen.dart';
import 'package:techgear/ui/screens/user/wish_screen.dart';
import 'package:techgear/ui/screens/user/home_screen.dart';
import 'package:techgear/ui/screens/auth/login_screen.dart';
import 'package:techgear/ui/screens/user/product_detail_screen.dart';
import 'package:techgear/ui/screens/auth/recover_password_screen.dart';
import 'package:techgear/ui/screens/auth/register_screen.dart';
import 'package:techgear/ui/screens/auth/welcome_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
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
      path: '/product-detail',
      builder: (context, state) {
        final String? productId = state.uri.queryParameters['productId'];
        final String? isAdminParam = state.uri.queryParameters['isAdmin'];

        final bool isAdmin =
            isAdminParam != null && isAdminParam.toLowerCase() == 'true';

        if (productId == null) {
          return Scaffold(
            body: Center(
              child: Text('Lỗi: Không tìm thấy Product ID'),
            ),
          );
        }

        return ProductDetailScreen(
          productId: productId,
          isAdmin: isAdmin,
        );
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
    GoRoute(
      path: '/manage-product',
      builder: (context, state) => const ManageProductScreen(),
    ),
    GoRoute(
      path: '/manage-product-variants/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        return ManageProductVariantsScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/add-product-variants/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        return AddProductVariantsScreen(
          productId: productId,
        );
      },
    ),
    GoRoute(
      path: '/manage-variant-options',
      builder: (context, state) => ManageVariantOptionsScreen(),
    ),
    GoRoute(
      path: '/add-variant-option',
      builder: (context, state) => AddVariantOptionScreen(),
    ),
  ],
);
