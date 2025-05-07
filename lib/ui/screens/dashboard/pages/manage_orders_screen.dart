import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/dtos/order_status_dto.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/ui/widgets/dialogs/custom_confirm_dialog.dart';
import 'package:techgear/ui/widgets/order/admin_order_card.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen>
    with SingleTickerProviderStateMixin {
  late OrderProvider _orderProvider;
  late TabController _tabController;

  final _noteController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _loadInformations();
  }

  Future<void> _loadInformations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _orderProvider.fetchAllOrders();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Cant load data. Please try again.';
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

  List<OrderDto> _filterOrdersByStatus(List<OrderDto> orders, String status) {
    return orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Orders",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            bottom: TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              overlayColor: WidgetStateProperty.all(Colors.grey[200]),
              indicatorColor: Colors.blue,
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "Confirmed"),
                Tab(text: "Shipped"),
                Tab(text: "Delivered"),
                Tab(text: "Canceled"),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style:
                                TextStyle(fontSize: 18, color: Colors.red[700]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadInformations,
                            child: const Text("Try again"),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(orderProvider, "Pending", context),
                        _buildTabContent(orderProvider, "Confirmed", context),
                        _buildTabContent(orderProvider, "Shipped", context),
                        _buildTabContent(orderProvider, "Delivered", context),
                        _buildTabContent(orderProvider, "Canceled", context),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildTabContent(
      OrderProvider orderProvider, String status, BuildContext context) {
    final filteredOrders = _filterOrdersByStatus(orderProvider.orders, status);
    final itemCount = filteredOrders.length;

    if (itemCount == 0) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No $status orders yet",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return _buildGroupedOrderList(filteredOrders);
  }

  Widget _buildGroupedOrderList(List<OrderDto> orders) {
    final groupedOrders = _groupOrdersByMonth(orders);
    final sortedMonthKeys = groupedOrders.keys.toList()
      ..sort((a, b) => b.compareTo(a));

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
              ...monthOrders.map(
                (order) => AdminOrderCard(
                  order: order,
                  onCancel: _orderProvider.isLoading
                      ? null
                      : () => _updateStatus(
                            OrderStatusDto(
                                orderId: order.id!, status: 'Canceled'),
                          ),
                  onConfirm: _orderProvider.isLoading
                      ? null
                      : () => _updateStatus(
                            OrderStatusDto(
                                orderId: order.id!, status: 'Confirmed'),
                          ),
                  onShip: _orderProvider.isLoading
                      ? null
                      : () => _updateStatus(
                            OrderStatusDto(
                                orderId: order.id!, status: 'Shipped'),
                          ),
                  onDeliver: _orderProvider.isLoading
                      ? null
                      : () => _updateStatus(
                            OrderStatusDto(
                                orderId: order.id!, status: 'Delivered'),
                          ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _updateStatus(OrderStatusDto orderStatus) async {
    if (_orderProvider.isLoading) return; // Ngăn gọi nhiều lần khi đang xử lý

    try {
      if (orderStatus.status == 'Canceled') {
        _showNoteBottomSheet(orderStatus);
      } else {
        _confirmUpdate(orderStatus);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    }
  }

  Future<void> _confirmUpdate(OrderStatusDto orderStatus) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: "Update Order #${orderStatus.orderId}",
        content:
            "Are you sure you want to update this order to ${orderStatus.status}?",
        confirmText: "Confirm",
        confirmColor: Colors.orange,
        onConfirmed: () async {
          await _orderProvider.updateOrderStatus(
              orderStatus.orderId, orderStatus);
        },
      ),
    );

    if (shouldCancel == true && _orderProvider.orderSuccess) {
      await _orderProvider.fetchAllOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order #${orderStatus.orderId} canceled")),
      );
    } else if (_orderProvider.errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${_orderProvider.errorMessage}")),
      );
    } else if (shouldCancel != true) {
      if (kDebugMode) print("Cancel action aborted");
    }
  }

  Future<void> _confirmCancel(OrderStatusDto orderStatus) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: "Cancel Order #${orderStatus.orderId}",
        content: "Are you sure you want to cancel this order?",
        confirmText: "Confirm",
        confirmColor: Colors.orange,
        onConfirmed: () async {
          await _orderProvider.updateOrderStatus(
              orderStatus.orderId, orderStatus);
        },
      ),
    );

    if (shouldCancel == true && _orderProvider.orderSuccess) {
      await _orderProvider.fetchAllOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order #${orderStatus.orderId} canceled")),
      );
    } else if (_orderProvider.errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${_orderProvider.errorMessage}")),
      );
    } else if (shouldCancel != true) {
      if (kDebugMode) print("Cancel action aborted");
    }
  }

  void _showNoteBottomSheet(OrderStatusDto orderStatus) {
    _noteController.clear(); // Xóa nội dung cũ
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Text(
                    "Add Note for Cancelation",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "Please provide a reason for canceling",
                      hintStyle: const TextStyle(fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    maxLines: 3,
                    cursorColor: Colors.black,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final cancelReason = _noteController.text.trim();
                          if (cancelReason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Please provide a cancel reason")),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          final updatedStatus = OrderStatusDto(
                            orderId: orderStatus.orderId,
                            status: orderStatus.status,
                            cancelReason: cancelReason,
                          );
                          _confirmCancel(updatedStatus);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
