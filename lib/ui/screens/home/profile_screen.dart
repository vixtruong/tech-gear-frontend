// lib/ui/screens/user/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/providers/auth_providers/auth_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/ui/widgets/dialogs/custom_confirm_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthProvider _authProvider;
  late SessionProvider _sessionProvider;
  String? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      setState(() {
        userId = _sessionProvider.userId;
      });
    } catch (e) {
      e.toString();
    }
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: 'Confirm Logout',
        content: 'Are you sure you want to log out?',
        confirmText: 'Logout',
        confirmColor: Colors.redAccent,
        onConfirmed: () async {
          try {
            await _authProvider.logout();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: userId == null
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "You are not logged in.",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Profile",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "User ID: $userId",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Wrap ListTile widgets in a Material widget
                Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Edit Profile"),
                        onTap: () {
                          // Add logic to edit profile
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text("Logout"),
                        onTap: () {
                          _logout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
