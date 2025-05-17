import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/best_selling_dto.dart';
import 'package:techgear/dtos/mock_data_dto.dart';
import 'package:techgear/dtos/total_order_dto.dart';
import 'package:techgear/dtos/total_user_dto.dart';
import 'package:techgear/providers/order_providers/order_provider.dart';
import 'package:techgear/providers/order_providers/statistic_provider.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProvider _userProvider;
  late OrderProvider _orderProvider;
  late StatisticProvider _statisticProvider;

  TotalUserDto? _totalUsers;
  TotalOrderDto? _totalOrders;

  List<BestSellingDto> _bestSelling = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _statisticProvider = Provider.of<StatisticProvider>(context, listen: false);
    _loadInfomation();
  }

  Future<void> _loadInfomation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchTotalUsers = await _userProvider.fetchTotalUser();
      final fetchTotalOrders = await _orderProvider.fetchTotalOrder();
      await _statisticProvider.fetchBestSelling();

      setState(() {
        _totalUsers = fetchTotalUsers;
        _totalOrders = fetchTotalOrders;
        _bestSelling = _statisticProvider.bestSelling;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInfomation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey[600],
                overlayColor: WidgetStateProperty.all(Colors.grey[200]),
                indicatorColor: Colors.blue,
                indicatorWeight: 2.0,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Simple'),
                  Tab(text: 'Advanced'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Responsive(
                    mobile: _buildSimpleDashboard(context, isMobile: true),
                    desktop: _buildSimpleDashboard(context, isMobile: false),
                  ),
                  Responsive(
                    mobile: _buildAdvancedDashboard(context, isMobile: true),
                    desktop: _buildAdvancedDashboard(context, isMobile: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDashboard(BuildContext context, {required bool isMobile}) {
    final vndFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSimpleMetricCards(context, isMobile, vndFormat),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                _buildBestSellingChart(context, _bestSelling),
                const SizedBox(height: 16),
                _buildRecentActivity(context),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 3,
                    child: _buildBestSellingChart(context, _bestSelling)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildRecentActivity(context)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedDashboard(BuildContext context,
      {required bool isMobile}) {
    return AdvancedDashboardContent(isMobile: isMobile);
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back, Admin!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSimpleMetricCards(
      BuildContext context, bool isMobile, NumberFormat vndFormat) {
    final List<Map<String, dynamic>> metrics = [
      {
        'title': 'Total Users',
        'value': '${_totalUsers?.totalUsers ?? 0}',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'New Users',
        'value': '${_totalUsers?.newUsers ?? 0}',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'title': 'Orders',
        'value': '${_totalOrders?.totalOrders ?? 0}',
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
      },
      {
        'title': 'Revenue',
        'value': vndFormat.format(_totalOrders?.totalRevenue ?? 0),
        'icon': Icons.attach_money,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: InkWell(
            onTap: () {}, // Add interaction if needed
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(metric['icon'], color: metric['color'], size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          metric['title'],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    metric['value'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: metric['color'],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBestSellingChart(
      BuildContext context, List<BestSellingDto> data) {
    final maxY = data
        .map((e) => e.sellingQuantity)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best-Selling Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + 10,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final category = data[group.x.toInt()].category;
                        return BarTooltipItem(
                          '$category\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sold: ${rod.toY.toInt()}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final label = data[index].category;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                label.length > 6
                                    ? label.substring(0, 6).toUpperCase()
                                    : label.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                  ),
                  barGroups: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.sellingQuantity.toDouble(),
                          width: 16,
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade900,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final List<Map<String, String>> activities = [
      {'description': 'Order #123 placed by John', 'time': '2h ago'},
      {'description': 'New user Jane signed up', 'time': '3h ago'},
      {'description': 'Stock alert: Keyboard x2 left', 'time': '4h ago'},
      {'description': 'Order #122 shipped', 'time': '6h ago'},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              itemCount: activities.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, thickness: 1),
              itemBuilder: (context, index) {
                final item = activities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.circle, color: Colors.blue, size: 10),
                  title: Text(
                    item['description']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item['time']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedDashboardContent extends StatefulWidget {
  final bool isMobile;

  const AdvancedDashboardContent({super.key, required this.isMobile});

  @override
  State<AdvancedDashboardContent> createState() =>
      _AdvancedDashboardContentState();
}

class _AdvancedDashboardContentState extends State<AdvancedDashboardContent> {
  String _selectedInterval = 'Annually';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _intervals = [
    'Annually',
    'Quarterly',
    'Monthly',
    'Weekly',
    'Custom'
  ];
  late StatisticProvider _statisticProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statisticProvider = Provider.of<StatisticProvider>(context, listen: false);
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    // Fetch best-selling data for all intervals
    await _statisticProvider.fetchBestSelling();

    // Fetch stats and comparative revenue based on selected interval
    switch (_selectedInterval) {
      case 'Annually':
        await _statisticProvider.fetchAnnualStats();
        await _statisticProvider.fetchAnnualRevenueComparison();
        break;
      case 'Quarterly':
        await _statisticProvider.fetchQuarterStats();
        await _statisticProvider.fetchQuarterlyRevenueComparison();
        break;
      case 'Monthly':
        await _statisticProvider.fetchMonthlyStats();
        await _statisticProvider.fetchMonthlyRevenueComparison();
        break;
      case 'Weekly':
        await _statisticProvider.fetchWeeklyStats();
        await _statisticProvider.fetchWeeklyRevenueComparison();
        break;
      case 'Custom':
        if (_startDate != null && _endDate != null) {
          await _statisticProvider.fetchCustomStats(_startDate!, _endDate!);
        }
        break;
    }
  }

  void _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedInterval = 'Custom';
      });
      await _fetchStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vndFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isMobile ? 16.0 : 24.0),
      child: Consumer<StatisticProvider>(
        builder: (context, statisticProvider, child) {
          if (statisticProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }
          if (statisticProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${statisticProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchStats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedInterval,
                      decoration: InputDecoration(
                        labelText: 'Time Interval',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      items: _intervals.map((interval) {
                        return DropdownMenuItem(
                          value: interval,
                          child: Text(interval,
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedInterval = value!;
                          if (value != 'Custom') {
                            _startDate = null;
                            _endDate = null;
                          }
                        });
                        if (value == 'Custom') {
                          _selectCustomDateRange(context);
                        } else {
                          await _fetchStats();
                        }
                      },
                    ),
                  ),
                  if (_selectedInterval == 'Custom' && _startDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'From ${_startDate!.toIso8601String().split('T')[0]} to ${_endDate!.toIso8601String().split('T')[0]}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _buildAdvancedMetricCards(context, widget.isMobile,
                  statisticProvider.currentStats, vndFormat),
              const SizedBox(height: 24),
              if (_selectedInterval == 'Annually' &&
                  statisticProvider.annualRevenueComparison != null) ...[
                _buildRevenueChart(
                  context,
                  statisticProvider.annualRevenueComparison!.currentPeriod,
                  'Current Year Revenue',
                  Colors.blue.shade900,
                ),
                const SizedBox(height: 24),
                _buildRevenueChart(
                  context,
                  statisticProvider.annualRevenueComparison!.previousPeriod,
                  'Previous Year Revenue',
                  Colors.blue,
                ),
              ],
              if (_selectedInterval == 'Quarterly' &&
                  statisticProvider.quarterlyRevenueComparison != null) ...[
                _buildRevenueChart(
                  context,
                  statisticProvider.quarterlyRevenueComparison!.currentPeriod,
                  'Current Quarter Revenue',
                  Colors.blue.shade900,
                ),
                const SizedBox(height: 24),
                _buildRevenueChart(
                  context,
                  statisticProvider.quarterlyRevenueComparison!.previousPeriod,
                  'Previous Quarter Revenue',
                  Colors.blue,
                ),
              ],
              if (_selectedInterval == 'Monthly' &&
                  statisticProvider.monthlyRevenueComparison != null) ...[
                _buildRevenueChart(
                  context,
                  statisticProvider.monthlyRevenueComparison!.currentPeriod,
                  'Current Month Revenue',
                  Colors.blue.shade900,
                ),
                const SizedBox(height: 24),
                _buildRevenueChart(
                  context,
                  statisticProvider.monthlyRevenueComparison!.previousPeriod,
                  'Previous Month Revenue',
                  Colors.blue,
                ),
              ],
              if (_selectedInterval == 'Weekly' &&
                  statisticProvider.weeklyRevenueComparison != null) ...[
                _buildRevenueChart(
                  context,
                  statisticProvider.weeklyRevenueComparison!.currentPeriod,
                  'Current Week Revenue',
                  Colors.blue.shade900,
                ),
                const SizedBox(height: 24),
                _buildRevenueChart(
                  context,
                  statisticProvider.weeklyRevenueComparison!.previousPeriod,
                  'Previous Week Revenue',
                  Colors.blue,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdvancedMetricCards(BuildContext context, bool isMobile,
      MockDataDto? stats, NumberFormat vndFormat) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final metrics = [
      {
        'title': 'Orders',
        'value': stats.totalOrders.toString(),
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
      {
        'title': 'Revenue',
        'value': vndFormat.format(stats.revenue),
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': 'Growth',
        'value': vndFormat.format(stats.growth),
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
      {
        'title': 'Growth %',
        'value': '${stats.growthPercent.toStringAsFixed(1)}%',
        'icon': Icons.percent,
        'color': Colors.orange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: InkWell(
            onTap: () {}, // Add interaction if needed
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(metric['icon'] as IconData,
                          color: metric['color'] as Color, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          metric['title'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    metric['value'] as String,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: metric['color'] as Color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart(
      BuildContext context, List data, String title, Color color) {
    final maxY =
        data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) + 10;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final period = data[group.x.toInt()];

                        String formatNumber(double val) {
                          if (val >= 1e9) {
                            return '${(val / 1e9).toStringAsFixed(1)}B'; // Tỷ
                          } else if (val >= 1e6) {
                            return '${(val / 1e6).toStringAsFixed(1)}M'; // Triệu
                          } else if (val >= 1e3) {
                            return '${(val / 1e3).toStringAsFixed(1)}K'; // Nghìn
                          } else {
                            return val.toInt().toString();
                          }
                        }

                        return BarTooltipItem(
                          '${period.periodName}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Revenue: ${formatNumber(rod.toY.toInt() as double)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 5,
                        getTitlesWidget: (value, meta) {
                          // Format số để ngắn gọn hơn, ví dụ 1000000 -> 1M
                          String formatNumber(double val) {
                            if (val >= 1e9) {
                              return '${(val / 1e9).toStringAsFixed(1)}B'; // Tỷ
                            } else if (val >= 1e6) {
                              return '${(val / 1e6).toStringAsFixed(1)}M'; // Triệu
                            } else if (val >= 1e3) {
                              return '${(val / 1e3).toStringAsFixed(1)}K'; // Nghìn
                            } else {
                              return val.toInt().toString();
                            }
                          }

                          return SizedBox(
                            width:
                                50, // Giới hạn chiều ngang để text không xuống dòng
                            child: Text(
                              formatNumber(value),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.right, // Căn phải cho đẹp
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final label = data[index].periodName;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                label.length > 6
                                    ? label.substring(0, 6).toUpperCase()
                                    : label.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                  ),
                  barGroups: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.revenue,
                          width: 16,
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.4),
                              color,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
