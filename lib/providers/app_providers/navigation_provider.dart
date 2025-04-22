import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    print('Selected Index updated to: $_selectedIndex');
    notifyListeners();
  }

  void syncWithRoute(String currentRoute) {
    final baseRoute = currentRoute.split('?').first;
    print('Syncing with route: $baseRoute');

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
    print('Selected Index set to: $_selectedIndex');
    notifyListeners();
  }
}
