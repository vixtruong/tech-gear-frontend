import 'package:flutter/material.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';

class ProfileCard extends StatefulWidget {
  final Function(bool, GlobalKey)
      onDropdownToggle; // Callback to notify MainScreen
  final GlobalKey cardKey; // Key to get position

  const ProfileCard(
      {super.key, required this.onDropdownToggle, required this.cardKey});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _isDropdownVisible = false;

  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
      widget.onDropdownToggle(_isDropdownVisible, widget.cardKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.cardKey,
      onTap: _toggleDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _isDropdownVisible
              ? Colors.white
                  .withOpacity(0.3) // More opaque when dropdown is open
              : Colors.white.withOpacity(0.1), // Original semi-transparent
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              child: Image.asset(
                "assets/images/tech_gear_logo.png",
                height: 38,
              ),
            ),
            if (!Responsive.isMobile(context))
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Admin",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
