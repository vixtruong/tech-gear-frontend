// lib/ui/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:badges/badges.dart' as badges;

class HomeBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeBottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    // Get the current route and sync the selectedIndex
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.syncWithRoute(currentRoute);

    // Use the selectedIndex from NavigationProvider
    final selectedIndex =
        Provider.of<NavigationProvider>(context).selectedIndex;

    const chatItemCount = 3; // Replace with dynamic value if needed

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: selectedIndex,
      onTap: (index) {
        Provider.of<NavigationProvider>(context, listen: false)
            .setSelectedIndex(index);
        navigationShell.goBranch(index);
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: "Activities",
        ),
        BottomNavigationBarItem(
          icon: badges.Badge(
            badgeContent: Text(
              '$chatItemCount',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: Icon(Icons.chat_outlined),
          ),
          activeIcon: badges.Badge(
            badgeContent: Text(
              '$chatItemCount',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: Icon(Icons.chat),
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: "User",
        ),
      ],
    );
  }
}
