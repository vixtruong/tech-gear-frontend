import 'package:flutter/material.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/screens/home_content.dart';
import 'package:techgear/widgets/custom_dropdown.dart';
import 'package:techgear/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const Center(child: Text("Categories Page")),
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
    return Scaffold(
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
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.widgets_outlined), label: "Categories"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined), label: "Cart"),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
          ],
        ),
      ),
    );
  }
}
