// lib/ui/widgets/web_layout.dart
import 'package:flutter/material.dart';
import 'package:techgear/ui/widgets/navbar/home/home_web_nav_bar.dart';

class UserWebLayout extends StatelessWidget {
  final Widget child;

  const UserWebLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext innerContext) {
        final isWeb = MediaQuery.of(innerContext).size.width > 800;

        return Scaffold(
          appBar: isWeb
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(100),
                  child: HomeWebNavBar(),
                )
              : null,
          body: child,
        );
      },
    );
  }
}
