import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/core/firebase_options.dart';
import 'package:techgear/core/routes.dart';
import 'package:techgear/providers/brand_provider.dart';
import 'package:techgear/providers/category_provider.dart';
import 'package:techgear/providers/product_item_provider.dart';
import 'package:techgear/providers/product_provider.dart';
import 'package:techgear/providers/variant_option_provider.dart';
import 'package:techgear/providers/variant_value_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProductProvider()),
      ChangeNotifierProvider(create: (context) => BrandProvider()),
      ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ChangeNotifierProvider(create: (context) => ProductItemProvider()),
      ChangeNotifierProvider(create: (context) => VariantOptionProvider()),
      ChangeNotifierProvider(create: (context) => VariantValueProvider()),
    ],
    child: App(),
  ));
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
