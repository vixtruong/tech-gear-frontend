import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
