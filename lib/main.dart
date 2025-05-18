import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/controllers/map_dashboard_controller.dart';
import 'package:techgear/core/routes.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/chat_providers/chat_provider.dart';
import 'package:techgear/providers/order_providers/cart_provider.dart';
import 'package:techgear/providers/order_providers/coupon_provider.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/providers/order_providers/statistic_provider.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_config_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/providers/product_providers/rating_provider.dart';
import 'package:techgear/providers/product_providers/search_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';
import 'package:techgear/providers/user_provider/favorite_provider.dart';
import 'package:techgear/providers/user_provider/loyalty_provider.dart';
import 'package:techgear/providers/user_provider/user_address_provider.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';
import 'package:techgear/services/order_service/cart_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        // Providers that don't depend on SessionProvider
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),

        // CartProvider (depends on SessionProvider for CartService)
        ChangeNotifierProxyProvider<SessionProvider, CartProvider>(
          create: (context) => CartProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, cartProvider) =>
              cartProvider ?? CartProvider(sessionProvider),
        ),

        // AuthProvider (depends on SessionProvider and CartService)
        ChangeNotifierProxyProvider<SessionProvider, AuthProvider>(
          create: (context) {
            final sessionProvider =
                Provider.of<SessionProvider>(context, listen: false);
            return AuthProvider(
              sessionProvider,
              CartService(sessionProvider),
            );
          },
          update: (context, sessionProvider, authProvider) =>
              authProvider ??
              AuthProvider(
                sessionProvider,
                CartService(sessionProvider),
              ),
        ),

        // Product-related Providers (all depend on SessionProvider)
        ChangeNotifierProxyProvider<SessionProvider, ProductProvider>(
          create: (context) => ProductProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, productProvider) =>
              productProvider ?? ProductProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, BrandProvider>(
          create: (context) => BrandProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, brandProvider) =>
              brandProvider ?? BrandProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, CategoryProvider>(
          create: (context) => CategoryProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, categoryProvider) =>
              categoryProvider ?? CategoryProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, ProductItemProvider>(
          create: (context) => ProductItemProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, productItemProvider) =>
              productItemProvider ?? ProductItemProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, VariantOptionProvider>(
          create: (context) => VariantOptionProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, variantOptionProvider) =>
              variantOptionProvider ?? VariantOptionProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, VariantValueProvider>(
          create: (context) => VariantValueProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, variantValueProvider) =>
              variantValueProvider ?? VariantValueProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, ProductConfigProvider>(
          create: (context) => ProductConfigProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, productConfigProvider) =>
              productConfigProvider ?? ProductConfigProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, RatingProvider>(
          create: (context) => RatingProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, ratingProvider) =>
              ratingProvider ?? RatingProvider(sessionProvider),
        ),

        // Order-related Providers
        ChangeNotifierProxyProvider<SessionProvider, OrderProvider>(
          create: (context) => OrderProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, orderProvider) =>
              orderProvider ?? OrderProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, CouponProvider>(
          create: (context) => CouponProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, orderProvider) =>
              orderProvider ?? CouponProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, StatisticProvider>(
          create: (context) => StatisticProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, orderProvider) =>
              orderProvider ?? StatisticProvider(sessionProvider),
        ),

        // UserProvider (depends on SessionProvider)
        ChangeNotifierProxyProvider<SessionProvider, UserProvider>(
          create: (context) => UserProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, userProvider) =>
              userProvider ?? UserProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, UserAddressProvider>(
          create: (context) => UserAddressProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, userAddressProvider) =>
              userAddressProvider ?? UserAddressProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, LoyaltyProvider>(
          create: (context) => LoyaltyProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, userAddressProvider) =>
              userAddressProvider ?? LoyaltyProvider(sessionProvider),
        ),
        ChangeNotifierProxyProvider<SessionProvider, FavoriteProvider>(
          create: (context) => FavoriteProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, userAddressProvider) =>
              userAddressProvider ?? FavoriteProvider(sessionProvider),
        ),

        // ChatProvider (depends on SessionProvider)
        ChangeNotifierProxyProvider<SessionProvider, ChatProvider>(
          create: (context) => ChatProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, chatProvider) =>
              chatProvider ?? ChatProvider(sessionProvider),
        ),

        // Map controller
        ChangeNotifierProvider(
          create: (context) => MenuAppController(),
        ),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const App(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black87,
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.blue,
        ),
      ),
      routerConfig: router,
    );
  }
}
