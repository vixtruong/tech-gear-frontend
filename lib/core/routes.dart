import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/cart/cart_item.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/ui/screens/dashboard/pages/chat_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/dashboard_screen.dart';
import 'package:techgear/ui/screens/dashboard/main_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/add_brand_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/add_category_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/add_product_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/add_product_variants_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/add_variant_option_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/manage_chats.dart';
import 'package:techgear/ui/screens/dashboard/pages/manage_product_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/manage_variant_options_screen.dart';
import 'package:techgear/ui/screens/dashboard/pages/manage_product_variants_screen.dart';
import 'package:techgear/ui/screens/home/activity_screen.dart';
import 'package:techgear/ui/screens/home/cart_screen.dart';
import 'package:techgear/ui/screens/home/change_password_screen.dart';
import 'package:techgear/ui/screens/home/edit_profile_screen.dart';
import 'package:techgear/ui/screens/home/manage_addresses.dart';
import 'package:techgear/ui/screens/home/support_center_screen.dart';
import 'package:techgear/ui/screens/home/checkout_screen.dart';
import 'package:techgear/ui/screens/home/home_screen.dart';
import 'package:techgear/ui/screens/home/product_detail_web_screen.dart';
import 'package:techgear/ui/layouts/user_web_layout.dart';
import 'package:techgear/ui/screens/home/rate_order_screen.dart';
import 'package:techgear/ui/screens/home/wish_list_screen.dart';
import 'package:techgear/ui/screens/auth/login_screen.dart';
import 'package:techgear/ui/screens/home/product_detail_screen.dart';
import 'package:techgear/ui/screens/auth/recover_password_screen.dart';
import 'package:techgear/ui/screens/auth/register_screen.dart';
import 'package:techgear/ui/screens/auth/welcome_screen.dart';
import 'package:techgear/ui/screens/home/profile_screen.dart';
import 'package:techgear/ui/widgets/navbar/home/home_bottom_nav_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/welcome', // Đặt initialLocation về /welcome
  redirect: (BuildContext context, GoRouterState state) async {
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    await sessionProvider.loadSession();

    final isLoggedIn = sessionProvider.isLoggedIn;
    final role = sessionProvider.role;

    // Danh sách các route chỉ dành cho Admin
    const adminRoutes = [
      '/dashboard',
      '/add-brand',
      '/add-category',
      '/add-product',
      '/manage-product',
      '/manage-product-variants/:productId',
      '/add-product-variants/:productId',
      '/manage-variant-options',
      '/add-variant-option',
      '/chats',
      '/chats/:userId',
    ];

    // Kiểm tra nếu route hiện tại là route admin
    bool isAdminRoute = adminRoutes.any((route) {
      if (route.contains(':') && state.uri.toString().contains('/')) {
        // Xử lý các route có tham số (ví dụ: /chats/:userId)
        final routePrefix = route.split('/:')[0];
        return state.uri.toString().startsWith(routePrefix);
      }
      return state.uri.toString().startsWith(route);
    });

    // Nếu chưa đăng nhập và cố truy cập route admin
    if (!isLoggedIn && isAdminRoute) {
      return '/welcome';
    }

    // Nếu đã đăng nhập nhưng không phải Admin và cố truy cập route admin
    if (isLoggedIn && role != 'Admin' && isAdminRoute) {
      return '/home';
    }

    // Nếu đã đăng nhập và cố truy cập các màn hình auth
    if (isLoggedIn) {
      if (state.uri.toString().startsWith('/welcome') ||
          state.uri.toString().startsWith('/login') ||
          state.uri.toString().startsWith('/register') ||
          state.uri.toString().startsWith('/recover-password')) {
        return role == 'Admin' ? '/dashboard' : '/home';
      }
    }

    return null;
  },

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
              path: '/support-center',
              builder: (context, state) => const SupportCenterScreen(),
            ),
          ],
        ),
        // Profile branch
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

        // Conditional rendering based on the `isAdmin` flag
        if (isWeb) {
          if (isAdmin) {
            return screen; // Show MainScreen for admins
          } else {
            return UserWebLayout(
                child: screen); // Show UserWebLayout for regular users
          }
        } else {
          return screen;
        }
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

    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        final extra = state.extra;
        final cartItems = (extra is List<CartItem>) ? extra : <CartItem>[];

        return isWeb
            ? UserWebLayout(child: CheckoutScreen(cartItems: cartItems))
            : CheckoutScreen(cartItems: cartItems);
      },
    ),

    GoRoute(
      path: '/rate-order/:orderId',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        final orderId = int.parse(state.pathParameters['orderId']!);
        return isWeb
            ? UserWebLayout(child: RateOrderScreen(orderId: orderId))
            : RateOrderScreen(orderId: orderId);
      },
    ),

    GoRoute(
      path: '/change-password',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: ChangePasswordScreen())
            : ChangePasswordScreen();
      },
    ),

    GoRoute(
      path: '/edit-profile',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: EditProfileScreen())
            : EditProfileScreen();
      },
    ),

    GoRoute(
      path: '/addresses',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width > 800;
        return isWeb
            ? UserWebLayout(child: ManageAddresses())
            : ManageAddresses();
      },
    ),

    // Admin screens
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        return MainScreen(screen: DashboardScreen(), title: "Dashboard");
      },
    ),

    GoRoute(
      path: '/add-brand',
      builder: (context, state) {
        return MainScreen(screen: AddBrandScreen(), title: "Add Brand");
      },
    ),
    GoRoute(
      path: '/add-category',
      builder: (context, state) {
        return MainScreen(screen: AddCategoryScreen(), title: "Add Category");
      },
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) {
        return MainScreen(screen: AddProductScreen(), title: "Add Product");
      },
    ),
    GoRoute(
      path: '/manage-product',
      builder: (context, state) {
        return MainScreen(
          screen: ManageProductScreen(),
          title: "Products",
        );
      },
    ),
    GoRoute(
      path: '/manage-product-variants/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        final screen = ManageProductVariantsScreen(productId: productId);
        return MainScreen(
          screen: screen,
          title: "Product Variations",
        );
      },
    ),
    GoRoute(
      path: '/add-product-variants/:productId',
      builder: (context, state) {
        final String productId = state.pathParameters['productId']!;
        final screen = AddProductVariantsScreen(productId: productId);
        return MainScreen(
          screen: screen,
          title: "Add product variation",
        );
      },
    ),
    GoRoute(
      path: '/manage-variant-options',
      builder: (context, state) {
        return MainScreen(
          screen: ManageVariantOptionsScreen(),
          title: "Variations",
        );
      },
    ),
    GoRoute(
      path: '/add-variant-option',
      builder: (context, state) {
        return MainScreen(
          screen: AddVariantOptionScreen(),
          title: "Add Variation",
        );
      },
    ),

    GoRoute(
      path: '/chats',
      builder: (context, state) {
        return MainScreen(
          screen: ManageChats(),
          title: "Messages",
        );
      },
    ),

    GoRoute(
      path: '/chats/:userId',
      builder: (context, state) {
        final userId = int.parse(state.pathParameters['userId']!);

        final userName =
            (state.extra is Map && (state.extra as Map).containsKey('userName'))
                ? (state.extra as Map)['userName'] as String
                : '';
        return MainScreen(
          screen: ChatScreen(customerId: userId, userName: userName),
          title: "Messages",
        );
      },
    ),
  ],
);
