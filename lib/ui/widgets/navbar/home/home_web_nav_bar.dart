import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/chat_providers/chat_provider.dart';
import 'package:techgear/providers/order_providers/cart_provider.dart';

class HomeWebNavBar extends StatefulWidget {
  const HomeWebNavBar({super.key});

  @override
  State<HomeWebNavBar> createState() => _HomeWebNavBarState();
}

class _HomeWebNavBarState extends State<HomeWebNavBar> {
  late CartProvider _cartProvider;
  late ChatProvider _chatProvider;
  bool _isCartLoaded = false;
  bool _isUnreadCountLoaded = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Defer syncWithRoute until after the first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentRoute = GoRouter.of(context)
          .routerDelegate
          .currentConfiguration
          .uri
          .toString();
      Provider.of<NavigationProvider>(context, listen: false)
          .syncWithRoute(currentRoute);
    });

    // Start polling for unread count updates (optional)
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (!_isCartLoaded) {
      _loadCart();
      _isCartLoaded = true;
    }
    if (!_isUnreadCountLoaded) {
      _loadUnreadCount();
      _isUnreadCountLoaded = true;
    }
  }

  Future<void> _loadCart() async {
    try {
      await _cartProvider.loadCart();
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);

      await sessionProvider.loadSession();
      final userId = sessionProvider.userId;

      if (userId != null) {
        await _chatProvider.fetchUnreadMessageCount(1, int.parse(userId));
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  // Optional: Poll for unread count updates every 30 seconds
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);
      final userId = sessionProvider.userId;
      if (userId != null) {
        await _loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                icon: Consumer<CartProvider>(
                  builder: (context, cartProvider, _) {
                    return badges.Badge(
                      badgeContent: Text(
                        '${cartProvider.itemCount}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined),
                    );
                  },
                ),
                onPressed: () => context.go('/cart'),
              ),
              const SizedBox(width: 20),
              _buildTopNavItem(Icons.home_outlined, 0, "Home", context),
              _buildTopNavItem(
                  Icons.article_outlined, 1, "Activities", context),
              _buildTopNavItemWithBadge(
                  Icons.chat_outlined, 2, "Support", context),
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
        context.go('/support-center');
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
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return badges.Badge(
                  showBadge: chatProvider.unreadCount > 0,
                  badgeContent: Text(
                    '${chatProvider.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Icon(
                    isSelected ? _getFilledIcon(icon) : icon,
                    color: isSelected ? Colors.black : Colors.black54,
                  ),
                );
              },
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
