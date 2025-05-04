import 'dart:async';
import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  final _routeChangeController = StreamController<int>.broadcast();

  int get selectedIndex => _selectedIndex;
  Stream<int> get routeChanges => _routeChangeController.stream;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      _routeChangeController.add(index);
      notifyListeners();
    }
  }

  void syncWithRoute(String currentRoute) {
    final baseRoute = currentRoute.split('?').first;
    print('Syncing with route: $baseRoute');

    int newIndex;
    switch (baseRoute) {
      case '/home':
        newIndex = 0;
        break;
      case '/activity':
        newIndex = 1;
        break;
      case '/support-center':
        newIndex = 2;
        break;
      case '/profile':
        newIndex = 3;
        break;
      default:
        newIndex = kIsWeb ? -1 : 0;
    }

    if (_selectedIndex != newIndex) {
      _selectedIndex = newIndex;
      _routeChangeController.add(newIndex);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _routeChangeController.close();
    super.dispose();
  }
}
