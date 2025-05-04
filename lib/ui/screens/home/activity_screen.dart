// lib/ui/screens/activity_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/dtos/rating_review_dto.dart';
import 'package:techgear/providers/app_providers/navigation_provider.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/providers/product_providers/rating_provider.dart';
import 'package:techgear/ui/widgets/order/order_card.dart';
import 'package:techgear/ui/widgets/product/rating_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late OrderProvider _orderProvider;
  late SessionProvider _sessionProvider;
  late TabController _tabController;
  late RatingProvider _ratingProvider;

  bool _isLoading = true;
  String? _errorMessage;

  String? userId;

  List<RatingReviewDto> ratings = [];

  StreamSubscription<int>? _routeSubscription;

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 4 tab
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _routeSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    _loadInformations();

    // Đăng ký lắng nghe Stream trong lần đầu tiên
    if (_routeSubscription == null) {
      final navigationProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      _routeSubscription = navigationProvider.routeChanges.listen((index) {
        if (index == 1 && !_isLoading) {
          _loadInformations();
        }
      });
    }
  }

  Future<void> _loadInformations() async {
    // if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _sessionProvider.loadSession();
      userId = _sessionProvider.userId;

      if (userId != null) {
        await _orderProvider.fetchOrdersByUserId(int.parse(userId!));
        await _ratingProvider.fetchRatingsByUserId(int.parse(userId!));

        setState(() {
          ratings = _ratingProvider.ratings;
        });
      }

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

  // Lọc đơn hàng theo trạng thái
  List<OrderDto> _filterOrdersByStatus(List<OrderDto> orders, String status) {
    return orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return userId == null && !_isLoading
        ? Container(
            color: Colors.grey[100],
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
        : Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              return Scaffold(
                backgroundColor: Colors.grey[100],
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  title: const Text(
                    "Activities",
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
                      Tab(text: "Rated"),
                    ],
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
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTabContent(orderProvider, "Pending",
                                  context), // Pending tab
                              _buildTabContent(orderProvider, "Confirmed",
                                  context), // Confirmed tab
                              _buildTabContent(orderProvider, "Shipped",
                                  context), // Shipped tab
                              _buildTabContent(
                                  orderProvider, "Delivered", context),
                              _buildRatedTab(context), // Delivered tab
                            ],
                          ),
              );
            },
          );
  }

  Widget _buildTabContent(
      OrderProvider orderProvider, String status, BuildContext context) {
    // Lọc đơn hàng theo trạng thái
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

  Widget _buildRatedTab(BuildContext context) {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        final ratings = ratingProvider.ratings;

        if (ratings.isEmpty) {
          return Center(
            child: Text(
              "You haven't rated any product yet.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        final groupedRatings = groupRatingsByOrderId(ratings);

        return RefreshIndicator(
          onRefresh: _loadInformations,
          color: Colors.blue,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: groupedRatings.entries.map((entry) {
              final orderId = entry.key;
              final ratingsOfOrder = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề đơn hàng
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Order #$orderId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Các rating của đơn hàng đó
                  ...ratingsOfOrder.map((rating) => RatingCard(rating: rating)),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Map<int, List<RatingReviewDto>> groupRatingsByOrderId(
      List<RatingReviewDto> ratings) {
    final Map<int, List<RatingReviewDto>> grouped = {};

    for (var rating in ratings) {
      if (!grouped.containsKey(rating.orderId)) {
        grouped[rating.orderId] = [];
      }
      grouped[rating.orderId]!.add(rating);
    }

    return grouped;
  }
}
