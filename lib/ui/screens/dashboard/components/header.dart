import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/controllers/map_dashboard_controller.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class Header extends StatelessWidget {
  final String title;

  const Header({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white, // Màu nền giống AppBar
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                context.read<MenuAppController>().openDrawer(context);
              },
            ),
          if (!Responsive.isDesktop(context)) SizedBox(width: 10),
          if (!Responsive.isMobile(context))
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          Expanded(
            child: CustomTextField(
              controller: TextEditingController(),
              hint: "Search",
              isSearch: true,
              inputType: TextInputType.text,
            ),
          ),
          ProfileCard(),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.0),
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/tech_gear_logo.png",
            height: 38,
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Admin"),
            ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
