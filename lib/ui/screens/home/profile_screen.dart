import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/user_dto.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';
import 'package:techgear/ui/widgets/dialogs/custom_confirm_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthProvider _authProvider;
  late SessionProvider _sessionProvider;
  late UserProvider _userProvider;

  String? userId;
  UserDto? user;
  String? initial;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadInfomation();
  }

  Future<void> _loadInfomation() async {
    try {
      _sessionProvider.loadSession();

      setState(() {
        userId = _sessionProvider.userId;
      });

      if (userId != null) {
        final fetchUser = await _userProvider.fetchUser(int.parse(userId!));

        setState(() {
          user = fetchUser;
          initial =
              user!.fullName.isNotEmpty ? user!.fullName[0].toUpperCase() : "?";
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : ListView(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black,
                            child: Text(
                              initial!,
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber[600],
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.white, width: 1),
                              ),
                              child: Text(
                                "${user?.point ?? 0} pts",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user!.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Email: ${user!.email}",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSectionTitle("My Services"),
                _buildGrabSection([
                  _buildTile(context,
                      icon: Icons.person_outline,
                      title: "Edit Profile", onTap: () {
                    if (kIsWeb) {
                    } else {}
                  }),
                  _buildTile(context,
                      icon: Icons.lock_outline,
                      title: "Change Password", onTap: () {
                    if (kIsWeb) {
                      context.go('/change-password');
                    } else {
                      context.push('/change-password');
                    }
                  }),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle("Rewards & Preferences"),
                _buildGrabSection([
                  _buildTile(context,
                      icon: Icons.star_border,
                      title: "Loyalty Program",
                      onTap: () {}),
                  _buildTile(context,
                      icon: Icons.location_on_outlined,
                      title: "Manage Addresses",
                      onTap: () {}),
                  _buildTile(context,
                      icon: Icons.card_giftcard_outlined,
                      title: "My Coupons",
                      onTap: () {}),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle("Other"),
                _buildGrabSection([
                  _buildTile(
                    context,
                    icon: Icons.logout,
                    title: "Logout",
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () => _logout(context),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildGrabSection(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++)
            Column(
              children: [
                tiles[i],
                if (i != tiles.length - 1)
                  const Divider(height: 1, thickness: 0.5, indent: 16),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.5, color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _logout(BuildContext context) async {
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
              // ignore: deprecated_member_use
              barrierColor: Colors.black.withOpacity(0.3),
              builder: (context) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            );

            await _authProvider.logout();

            if (outerContext.mounted) {
              outerContext.go('/login');
            }
          } catch (e) {
            debugPrint('Logout error: ${e.toString()}');
            SchedulerBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
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
