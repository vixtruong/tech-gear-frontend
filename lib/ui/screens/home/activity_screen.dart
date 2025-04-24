import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/ui/widgets/order/order_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late OrderProvider _orderProvider;
  late SessionProvider _sessionProvider;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _loadInformations();
  }

  Future<void> _loadInformations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _sessionProvider.loadSession();
      final userId = _sessionProvider.userId;

      if (userId != null) {
        await _orderProvider.fetchOrdersByUserId(int.parse(userId));
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
      });
    }
  }

  Map<String, List<OrderDto>> _groupOrdersByMonth(List<OrderDto> orders) {
    final Map<String, List<OrderDto>> grouped = {};

    for (var order in orders) {
      final key =
          '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(order);
    }

    // Sort từng nhóm theo ngày mới nhất trước
    for (var list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  String _formatMonthKey(String key) {
    final parts = key.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat.MMMM('en_US').format(DateTime(0, month));
    return '$monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final itemCount = orderProvider.orders.length;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Activities",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadInformations,
                            child: const Text("Try again"),
                          ),
                        ],
                      ),
                    )
                  : itemCount == 0
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "You have no activity yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.go('/home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Shop Now",
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
                      : _buildGroupedOrderList(orderProvider),
        );
      },
    );
  }

  Widget _buildGroupedOrderList(OrderProvider orderProvider) {
    final groupedOrders = _groupOrdersByMonth(orderProvider.orders);
    final sortedMonthKeys = groupedOrders.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest month first

    return RefreshIndicator(
      onRefresh: _loadInformations,
      color: Colors.blue,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: sortedMonthKeys.map((monthKey) {
          final monthOrders = groupedOrders[monthKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  _formatMonthKey(monthKey),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...monthOrders.map((order) => OrderCard(order: order)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
