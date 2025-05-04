import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techgear/models/user/user_address.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/user_provider/user_address_provider.dart';
import 'package:intl/intl.dart';
import 'package:techgear/ui/widgets/dialogs/custom_confirm_dialog.dart';

class ManageAddresses extends StatefulWidget {
  const ManageAddresses({super.key});

  @override
  State<ManageAddresses> createState() => _ManageAddressesState();
}

class _ManageAddressesState extends State<ManageAddresses> {
  late UserAddressProvider _addressProvider;
  late SessionProvider _sessionProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addressProvider = Provider.of<UserAddressProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _addressProvider.fetchUserAddresses();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAddressProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            elevation: kIsWeb ? 1 : 0,
            title: const Text(
              "Manage Addresses",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : provider.addresses.isEmpty
                  ? const Center(child: Text("No address found"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final address = provider.addresses[index];
                        return _buildAddressCard(address);
                      },
                    ),
          floatingActionButton: SpeedDial(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            animatedIcon: AnimatedIcons.menu_close,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            elevation: 2,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.add_circle, color: Colors.white),
                backgroundColor: Colors.green,
                label: 'Add New Address',
                labelStyle: const TextStyle(fontSize: 16),
                onTap: () {
                  if (kIsWeb) {
                    context.go('/add-address');
                  } else {
                    context.push('/add-address');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(UserAddress address) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.recipientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (address.isDefault)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Default",
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Phone: ${address.recipientPhone}"),
                const SizedBox(height: 4),
                Text("Address: ${address.address}"),
                const SizedBox(height: 4),
                Text(
                  "Created at: ${DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(address.createdAt)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    address.isDefault
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                    color: Colors.orange,
                  ),
                  tooltip:
                      address.isDefault ? 'Unset default' : 'Set as default',
                  onPressed: () {
                    if (!address.isDefault) {
                      _confirmSetDefault(address.id!);
                    }
                  },
                ),
                if (!address.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(address.id!);
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _setDefault(int addressId) async {
    try {
      await _sessionProvider.loadSession();

      final userId = _sessionProvider.userId;

      if (userId != null) {
        await _addressProvider.setDefaultAddress(int.parse(userId), addressId);
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<void> _confirmSetDefault(int addressId) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: "Set Default Address",
        content: "Are you sure you want to set this address default?",
        confirmText: "Set",
        confirmColor: Colors.orange,
        onConfirmed: () async {
          await _setDefault(addressId);
        },
      ),
    );
    if (shouldLogout != true) {
      debugPrint("Logout canceled");
    }
  }

  Future<void> _confirmDelete(int id) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: "Delete Address",
        content: "Are you sure you want to delete this address?",
        confirmText: "Delete",
        confirmColor: Colors.red,
        onConfirmed: () async {
          await _addressProvider.deleteAddress(id);
        },
      ),
    );
    if (shouldLogout != true) {
      debugPrint("Logout canceled");
    }
  }
}
