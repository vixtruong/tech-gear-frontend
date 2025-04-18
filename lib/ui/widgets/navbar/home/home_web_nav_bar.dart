// lib/ui/widgets/web_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:badges/badges.dart' as badges;

class HomeWebNavBar extends StatelessWidget {
  const HomeWebNavBar({super.key});

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Row(
              children: [
                Image.asset('assets/images/tech_gear_logo.png',
                    width: 40, height: 40),
                const SizedBox(width: 10),
                const Text(
                  'Tech Gear',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          if (selectedIndex == 0)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                height: 40,
                child: TextField(
                  cursorColor: Colors.black,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          if (selectedIndex != 0) const Expanded(child: Text("")),
          const SizedBox(width: 20),
          Row(
            children: [
              _iconBtn(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => context.go('/wish-list'),
              ),
              const SizedBox(width: 10),
              _iconBtn(
                icon: badges.Badge(
                  badgeContent: const Text('3',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                onPressed: () => context.go('/cart'),
              ),
              const SizedBox(width: 20),
              _buildTopNavItem(Icons.home_outlined, 0, "Home", context),
              _buildTopNavItem(
                  Icons.article_outlined, 1, "Activities", context),
              _buildTopNavItemWithBadge(
                  Icons.chat_outlined, 2, "Chat", context),
              _buildTopNavItem(Icons.person_outline, 3, "User", context),
            ],
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    Provider.of<NavigationProvider>(context, listen: false)
        .setSelectedIndex(index);
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/activity');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  Widget _buildTopNavItem(
      IconData icon, int index, String label, BuildContext context) {
    final isSelected =
        index == Provider.of<NavigationProvider>(context).selectedIndex;
    return GestureDetector(
      onTap: () => _navigate(context, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _getFilledIcon(icon) : icon,
              color: isSelected ? Colors.black : Colors.black54,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavItemWithBadge(
      IconData icon, int index, String label, BuildContext context) {
    final isSelected =
        index == Provider.of<NavigationProvider>(context).selectedIndex;
    return GestureDetector(
      onTap: () => _navigate(context, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badges.Badge(
              badgeContent: const Text('3',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              child: Icon(
                isSelected ? _getFilledIcon(icon) : icon,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({required Widget icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: IconButton(onPressed: onPressed, icon: icon),
    );
  }

  IconData _getFilledIcon(IconData outlinedIcon) {
    switch (outlinedIcon) {
      case Icons.home_outlined:
        return Icons.home;
      case Icons.article_outlined:
        return Icons.article;
      case Icons.chat_outlined:
        return Icons.chat;
      case Icons.person_outline:
        return Icons.person;
      default:
        return outlinedIcon;
    }
  }
}
