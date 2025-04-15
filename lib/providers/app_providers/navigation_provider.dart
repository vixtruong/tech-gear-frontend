import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void syncWithRoute(String currentRoute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baseRoute = currentRoute.split('?').first;

      switch (baseRoute) {
        case '/home':
          _selectedIndex = 0;
          break;
        case '/activity':
          _selectedIndex = 1;
          break;
        case '/chat':
          _selectedIndex = 2;
          break;
        case '/profile':
          _selectedIndex = 3;
          break;
        default:
          _selectedIndex = (kIsWeb) ? -1 : 0;
      }
      notifyListeners();
    });
  }
}
