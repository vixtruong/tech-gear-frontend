// lib/core/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techgear/ui/screens/dashboard/add_brand_screen.dart';
import 'package:techgear/ui/screens/dashboard/add_category_screen.dart';
import 'package:techgear/ui/screens/dashboard/add_product_screen.dart';
import 'package:techgear/ui/screens/dashboard/add_product_variants_screen.dart';
import 'package:techgear/ui/screens/dashboard/add_variant_option_screen.dart';
import 'package:techgear/ui/screens/dashboard/manage_product_screen.dart';
import 'package:techgear/ui/screens/dashboard/manage_variant_options_screen.dart';
import 'package:techgear/ui/screens/dashboard/manage_product_variants_screen.dart';
import 'package:techgear/ui/screens/home/activity_screen.dart';
import 'package:techgear/ui/screens/home/cart_screen.dart';
import 'package:techgear/ui/screens/home/chat_screen.dart';
import 'package:techgear/ui/screens/home/home_screen.dart';
import 'package:techgear/ui/screens/home/product_detail_web_screen.dart';
import 'package:techgear/ui/layouts/user_web_layout.dart';
import 'package:techgear/ui/screens/home/wish_list_screen.dart';
import 'package:techgear/ui/screens/auth/login_screen.dart';
import 'package:techgear/ui/screens/home/product_detail_screen.dart';
import 'package:techgear/ui/screens/auth/recover_password_screen.dart';
import 'package:techgear/ui/screens/auth/register_screen.dart';
import 'package:techgear/ui/screens/auth/welcome_screen.dart';
import 'package:techgear/ui/screens/home/profile_screen.dart';
import 'package:techgear/ui/widgets/navbar/home/home_bottom_nav_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Auth screens (no navbar needed)
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

    // Shell route for user screens (persistent bottom navigation on mobile)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: navigationShell)
            : Scaffold(
                body: navigationShell,
                bottomNavigationBar:
                    HomeBottomNavBar(navigationShell: navigationShell),
              );
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Activity branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              builder: (context, state) => const ActivityScreen(),
            ),
          ],
        ),
        // Chat branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        // Profile branch (static path)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Other user routes (outside the shell)
    GoRoute(
      path: '/product-detail',
      builder: (context, state) {
        final String? productId = state.uri.queryParameters['productId'];
        final String? isAdminParam = state.uri.queryParameters['isAdmin'];
        final bool isAdmin =
            isAdminParam != null && isAdminParam.toLowerCase() == 'true';

        if (productId == null) {
          return const Scaffold(
            body: Center(child: Text('Lỗi: Không tìm thấy Product ID')),
          );
        }

        final isWeb = MediaQuery.of(context).size.width > 800;
        final screen = isWeb
            ? ProductDetailScreenWeb(productId: productId, isAdmin: isAdmin)
            : ProductDetailScreen(productId: productId, isAdmin: isAdmin);

        return isWeb ? UserWebLayout(child: screen) : screen;
      },
    ),
    GoRoute(
      path: '/wish-list',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? const UserWebLayout(child: WishListScreen())
            : const WishListScreen();
      },
    ),

    GoRoute(
      path: '/cart',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? const UserWebLayout(child: CartScreen())
            : const CartScreen();
      },
    ),

    // Admin screens
    GoRoute(
      path: '/add-brand',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: AddBrandScreen())
            : AddBrandScreen();
      },
    ),
    GoRoute(
      path: '/add-category',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: AddCategoryScreen())
            : AddCategoryScreen();
      },
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? const UserWebLayout(child: AddProductScreen())
            : const AddProductScreen();
      },
    ),
    GoRoute(
      path: '/manage-product',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? const UserWebLayout(child: ManageProductScreen())
            : const ManageProductScreen();
      },
    ),
    GoRoute(
      path: '/manage-product-variants/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        final isWeb = MediaQuery.of(context).size.width > 800;
        final screen = ManageProductVariantsScreen(productId: productId);
        return isWeb ? UserWebLayout(child: screen) : screen;
      },
    ),
    GoRoute(
      path: '/add-product-variants/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        final isWeb = MediaQuery.of(context).size.width > 800;
        final screen = AddProductVariantsScreen(productId: productId);
        return isWeb ? UserWebLayout(child: screen) : screen;
      },
    ),
    GoRoute(
      path: '/manage-variant-options',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: ManageVariantOptionsScreen())
            : ManageVariantOptionsScreen();
      },
    ),
    GoRoute(
      path: '/add-variant-option',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: AddVariantOptionScreen())
            : AddVariantOptionScreen();
      },
    ),
  ],
);
