import 'package:flutter/foundation.dart';
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
        color: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                if (kIsWeb) {
                  context.go('/dashboard');
                } else {
                  context.push('/dashboard');
                }
              },
            ),
            DrawListTile(
              title: "Messages",
              iconPath: "assets/icons/menu_chat.svg",
              route: '/messages', // Define route even if not implemented
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Orders",
              iconPath: "assets/icons/menu_store.svg",
              route: '/orders', // Define route even if not implemented
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Products",
              iconPath: "assets/icons/menu_product.svg",
              route: '/manage-product',
              currentRoute: currentRoute,
              onTap: () {
                if (kIsWeb) {
                  context.go('/manage-product');
                } else {
                  context.push('/manage-product');
                }
              },
            ),
            DrawListTile(
              title: "Variations",
              iconPath: "assets/icons/menu_setting.svg",
              route: '/manage-variant-options',
              currentRoute: currentRoute,
              onTap: () {
                if (kIsWeb) {
                  context.go('/manage-variant-options');
                } else {
                  context.push('/manage-variant-options');
                }
              },
            ),
            DrawListTile(
              title: "Brands",
              iconPath: "assets/icons/menu_brand.svg",
              route: '/brands', // Define route even if not implemented
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Categories",
              iconPath: "assets/icons/menu_category.svg",
              route: '/categories', // Define route even if not implemented
              currentRoute: currentRoute,
              onTap: () {},
            ),
            DrawListTile(
              title: "Transactions",
              iconPath: "assets/icons/menu_tran.svg",
              route: '/transactions', // Define route even if not implemented
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
            ? Colors.blue[100] // Highlight for active route
            : _isHovering
                ? Colors.grey[200] // Hover effect
                : Colors.transparent,
        child: ListTile(
          onTap: widget.onTap,
          horizontalTitleGap: 10.0,
          leading: SvgPicture.asset(
            widget.iconPath,
            width: 18,
            colorFilter: isActive
                ? ColorFilter.mode(
                    Colors.blue, BlendMode.srcIn) // Tint icon when active
                : null,
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
