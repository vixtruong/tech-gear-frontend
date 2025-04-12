import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/core/routes.dart';
import 'package:techgear/providers/product_providers/brand_provider.dart';
import 'package:techgear/providers/product_providers/category_provider.dart';
import 'package:techgear/providers/product_providers/product_config_provider.dart';
import 'package:techgear/providers/product_providers/product_item_provider.dart';
import 'package:techgear/providers/product_providers/product_provider.dart';
import 'package:techgear/providers/product_providers/variant_option_provider.dart';
import 'package:techgear/providers/product_providers/variant_value_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => BrandProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => ProductItemProvider()),
        ChangeNotifierProvider(create: (context) => VariantOptionProvider()),
        ChangeNotifierProvider(create: (context) => VariantValueProvider()),
        ChangeNotifierProvider(create: (context) => ProductConfigProvider()),
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
      ),
      routerConfig: router,
    );
  }
}
