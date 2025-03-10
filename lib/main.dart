import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techgear/core/firebase_options.dart';
import 'package:techgear/core/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
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
