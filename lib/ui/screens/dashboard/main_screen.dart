import 'package:flutter/material.dart';
import 'package:techgear/ui/screens/dashboard/components/side_menu.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';
import 'package:techgear/ui/screens/dashboard/components/header.dart';

class MainScreen extends StatefulWidget {
  final Widget screen;
  final String title;

  const MainScreen({super.key, required this.screen, required this.title});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      key: _scaffoldKey,
      drawer: Responsive.isDesktop(context) ? null : SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SideMenu cho desktop
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
              ),
            // Nội dung chính (Header + screen)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header chỉ nằm trên widget.screen
                  Header(title: widget.title),
                  // Nội dung chính
                  Expanded(
                    child: widget.screen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
