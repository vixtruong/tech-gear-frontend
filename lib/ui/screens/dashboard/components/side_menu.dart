import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current route
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Container(
        color: Colors.white, // Nền trắng giống Zalo
        child: ListView(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Nền xám nhạt cho header
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/tech_gear_logo.png',
                    width: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Tech Gear",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            DrawListTile(
              title: "Dashboard",
              iconPath: "assets/icons/menu_dashboard.svg",
              route: '/dashboard',
              currentRoute: currentRoute,
              onTap: () {
                context.go('/dashboard');
              },
            ),
            DrawListTile(
              title: "Messages",
              iconPath: "assets/icons/menu_chat.svg",
              route: '/chats',
              currentRoute: currentRoute,
              onTap: () {
                context.go('/chats');
              },
            ),
            DrawListTile(
              title: "Orders",
              iconPath: "assets/icons/menu_store.svg",
              route: '/orders',
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Products",
              iconPath: "assets/icons/menu_product.svg",
              route: '/manage-product',
              currentRoute: currentRoute,
              onTap: () {
                context.go('/manage-product');
              },
            ),
            DrawListTile(
              title: "Variations",
              iconPath: "assets/icons/menu_setting.svg",
              route: '/manage-variant-options',
              currentRoute: currentRoute,
              onTap: () {
                context.go('/manage-variant-options');
              },
            ),
            DrawListTile(
              title: "Brands",
              iconPath: "assets/icons/menu_brand.svg",
              route: '/brands',
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Categories",
              iconPath: "assets/icons/menu_category.svg",
              route: '/categories',
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Transactions",
              iconPath: "assets/icons/menu_tran.svg",
              route: '/transactions',
              currentRoute: currentRoute,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class DrawListTile extends StatefulWidget {
  final String iconPath;
  final String title;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const DrawListTile({
    super.key,
    required this.iconPath,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  State<DrawListTile> createState() => _DrawListTileState();
}

class _DrawListTileState extends State<DrawListTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Check if this tile's route matches the current route
    bool isActive = widget.route == widget.currentRoute;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        color: isActive
            ? const Color(0xFF0068FF)
                // ignore: deprecated_member_use
                .withOpacity(0.1)
            : _isHovering
                ? Colors.grey[300]
                : Colors.transparent,
        child: ListTile(
          onTap: widget.onTap,
          horizontalTitleGap: 12.0, // Tăng gap cho thoáng
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 4.0), // Padding tinh tế
          leading: SvgPicture.asset(
            widget.iconPath,
            width: 20, // Tăng kích thước icon
            colorFilter: isActive
                ? const ColorFilter.mode(Color(0xFF0068FF), BlendMode.srcIn)
                : ColorFilter.mode(Colors.grey[700]!, BlendMode.srcIn),
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15, // Font size tinh tế
              color: isActive ? const Color(0xFF0068FF) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
