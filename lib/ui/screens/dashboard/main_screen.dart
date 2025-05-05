import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/ui/screens/dashboard/components/profile_card.dart';
import 'package:techgear/ui/screens/dashboard/components/side_menu.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';
import 'package:techgear/ui/screens/dashboard/components/header.dart';
import 'package:techgear/ui/widgets/dialogs/custom_confirm_dialog.dart';

class MainScreen extends StatefulWidget {
  final Widget screen;
  final String title;

  const MainScreen({super.key, required this.screen, required this.title});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDropdownVisible = false;
  GlobalKey? _profileCardKey;
  Offset _dropdownPosition = Offset.zero;
  double _profileCardWidth =
      180.0; // Default width, will be updated dynamically

  void _handleDropdownToggle(bool isVisible, GlobalKey cardKey) {
    setState(() {
      _isDropdownVisible = isVisible;
      _profileCardKey = cardKey;
      if (isVisible && cardKey.currentContext != null) {
        final RenderBox box =
            cardKey.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        _dropdownPosition = Offset(
          position.dx,
          position.dy + box.size.height, // Position below the ProfileCard
        );
        _profileCardWidth = box.size.width; // Get the ProfileCard's width
      }
    });
  }

  Future<void> _handleOptionTap(String option) async {
    setState(() {
      _isDropdownVisible = false;
    });
    if (option == 'change_password') {
      if (kIsWeb) {
        context.go('/change-password');
      } else {
        context.push('/change-password');
      }
    } else if (option == 'logout') {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await _logout(context, authProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileCardKey = GlobalKey(); // Key for ProfileCard

    return Scaffold(
      backgroundColor: Colors.grey[100],
      key: _scaffoldKey,
      drawer: Responsive.isDesktop(context) ? null : SideMenu(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SideMenu for desktop
                if (Responsive.isDesktop(context))
                  Expanded(
                    child: SideMenu(),
                  ),
                // Main content (Header + screen)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Header(
                        title: widget.title,
                        profileCard: ProfileCard(
                          cardKey: profileCardKey,
                          onDropdownToggle: _handleDropdownToggle,
                        ),
                      ),
                      // Main content
                      Expanded(
                        child: widget.screen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Dropdown
            if (_isDropdownVisible && _profileCardKey != null)
              Positioned(
                left: _dropdownPosition.dx,
                top: _dropdownPosition.dy,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: _profileCardWidth, // Use ProfileCard's width
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Change Password Option
                        InkWell(
                          onTap: () => _handleOptionTap('change_password'),
                          splashColor: Colors.grey.withOpacity(1),
                          highlightColor: Colors.grey.withOpacity(0.1),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Text(
                              'Change Password',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          height: 1,
                          color: Colors.white10,
                        ),
                        // Logout Option
                        InkWell(
                          onTap: () => _handleOptionTap('logout'),
                          splashColor: Colors.grey.withOpacity(1),
                          highlightColor: Colors.grey.withOpacity(0.1),
                          child: Ink(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Text(
                              'Logout',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final outerContext = context;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: 'Confirm Logout',
        content: 'Are you sure you want to log out?',
        confirmText: 'Logout',
        confirmColor: Colors.redAccent,
        onConfirmed: () async {
          try {
            showDialog(
              context: outerContext,
              barrierDismissible: false,
              barrierColor: Colors.black.withOpacity(0.3),
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            );

            await authProvider.logout();

            if (outerContext.mounted) {
              outerContext.go('/login');
            }
          } catch (e) {
            debugPrint('Logout error: ${e.toString()}');
            SchedulerBinding.instance.addPostFrameCallback((_) {
              outerContext.go('/login');
            });
          }
        },
      ),
    );

    if (shouldLogout != true) {
      debugPrint("Logout canceled");
    }
  }
}
