import 'package:flutter/material.dart';
import 'package:techgear/ui/screens/user/home_page.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int chatItemCount = 3;

  final List<Widget> _screens = [
    HomePage(),
    const Center(child: Text("Cart Page")),
    const Center(child: Text("Chat Page")),
    const Center(child: Text("Menu Page")),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.black12,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onNavItemTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 2
                      ? Icons.article_outlined
                      : Icons.article_outlined,
                ),
                label: "Activities",
              ),
              BottomNavigationBarItem(
                icon: badges.Badge(
                  badgeContent: Text(
                    '$chatItemCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Icon(
                    _selectedIndex == 2 ? Icons.chat : Icons.chat_outlined,
                  ),
                ),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 3 ? Icons.person : Icons.person_outlined,
                ),
                label: "User",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
