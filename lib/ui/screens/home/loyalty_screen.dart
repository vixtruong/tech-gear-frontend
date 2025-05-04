import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/loyalty_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/user_provider/loyalty_provider.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late LoyaltyProvider _loyaltyProvider;
  late UserProvider _userProvider;
  late SessionProvider _sessionProvider;

  int? totalPoint;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    try {
      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;

      if (userId != null) {
        await _loyaltyProvider.fetchLoyalties(int.parse(userId));
        await _userProvider.fetchLoyaltyPoints();

        setState(() {
          totalPoint = _userProvider.loyaltyPoints;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, _) {
        final getList = provider.loyalties
            .where((e) => e.action == 'get')
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final useList = provider.loyalties
            .where((e) => e.action == 'use')
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            elevation: kIsWeb ? 1 : 0,
            title: const Text(
              "Loyalty Program",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      totalPoint?.toString() ?? '0',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              overlayColor: WidgetStateProperty.all(Colors.grey[200]),
              indicatorColor: Colors.blue,
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Get"),
                Tab(text: "Use"),
              ],
            ),
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
              : Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoyaltyList(getList),
                          _buildLoyaltyList(useList),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLoyaltyList(List<LoyaltyDto> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No data"));
    } else {
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return ListTile(
            leading: Icon(
              item.point >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
              color: item.point >= 0 ? Colors.green : Colors.red,
            ),
            title: Text("${item.point > 0 ? '+' : ''}${item.point} point"),
            subtitle: Text(
              DateFormat('dd-MM-yyyy HH:mm', 'vi_VN').format(item.createdAt),
            ),
            trailing: item.fromOrderId != null
                ? Text("Order #${item.fromOrderId}")
                : const Text("Không có đơn"),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      );
    }
  }
}
