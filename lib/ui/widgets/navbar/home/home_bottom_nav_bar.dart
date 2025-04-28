import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/chat_providers/chat_provider.dart';

class HomeBottomNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeBottomNavBar({super.key, required this.navigationShell});

  @override
  State<HomeBottomNavBar> createState() => _HomeBottomNavBarState();
}

class _HomeBottomNavBarState extends State<HomeBottomNavBar> {
  bool _isUnreadCountLoaded = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Fetch unread count after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isUnreadCountLoaded) {
        _loadUnreadCount();
        _isUnreadCountLoaded = true;
      }
    });

    // Start polling for unread count updates (optional)
    _startPolling();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);

      await sessionProvider.loadSession();
      final userId = sessionProvider.userId;

      if (userId != null) {
        await chatProvider.fetchUnreadMessageCount(1, int.parse(userId));
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

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: selectedIndex,
      onTap: (index) {
        Provider.of<NavigationProvider>(context, listen: false)
            .setSelectedIndex(index);
        widget.navigationShell.goBranch(index);
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: "Activities",
        ),
        BottomNavigationBarItem(
          icon: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return badges.Badge(
                showBadge: chatProvider.unreadCount > 0,
                badgeContent: Text(
                  '${chatProvider.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: const Icon(Icons.chat_outlined),
              );
            },
          ),
          activeIcon: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return badges.Badge(
                showBadge: chatProvider.unreadCount > 0,
                badgeContent: Text(
                  '${chatProvider.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: const Icon(Icons.chat),
              );
            },
          ),
          label: "Support",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: "User",
        ),
      ],
    );
  }
}
