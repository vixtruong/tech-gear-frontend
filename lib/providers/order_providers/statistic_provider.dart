import 'package:flutter/material.dart';
import 'package:techgear/dtos/mock_data_dto.dart';
import 'package:techgear/dtos/best_selling_dto.dart';
import 'package:techgear/dtos/payment_dto.dart';
import 'package:techgear/dtos/comparative_revenue_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/order_service/statistic_service.dart';

class StatisticProvider with ChangeNotifier {
  final StatisticService _statisticService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MockDataDto? _currentStats;
  MockDataDto? get currentStats => _currentStats;

  List<BestSellingDto> _bestSelling = [];
  List<BestSellingDto> get bestSelling => _bestSelling;

  List<PaymentDto> _payments = [];
  List<PaymentDto> get payments => _payments;

  // New properties for comparative revenue data
  ComparativeRevenueDto? _annualRevenueComparison;
  ComparativeRevenueDto? get annualRevenueComparison =>
      _annualRevenueComparison;

  ComparativeRevenueDto? _quarterlyRevenueComparison;
  ComparativeRevenueDto? get quarterlyRevenueComparison =>
      _quarterlyRevenueComparison;

  ComparativeRevenueDto? _monthlyRevenueComparison;
  ComparativeRevenueDto? get monthlyRevenueComparison =>
      _monthlyRevenueComparison;

  ComparativeRevenueDto? _weeklyRevenueComparison;
  ComparativeRevenueDto? get weeklyRevenueComparison =>
      _weeklyRevenueComparison;

  StatisticProvider(SessionProvider sessionProvider)
      : _statisticService = StatisticService(sessionProvider);

  Future<void> fetchPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await _statisticService.fetchPayments();
    } catch (e) {
      _errorMessage = e.toString();
      _payments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnnualStats() async {
    await _fetch(() => _statisticService.fetchAnnualStats());
  }

  Future<void> fetchQuarterStats() async {
    await _fetch(() => _statisticService.fetchQuarterStats());
  }

  Future<void> fetchMonthlyStats() async {
    await _fetch(() => _statisticService.fetchMonthlyStats());
  }

  Future<void> fetchWeeklyStats() async {
    await _fetch(() => _statisticService.fetchWeeklyStats());
  }

  Future<void> fetchCustomStats(DateTime start, DateTime end) async {
    await _fetch(() => _statisticService.fetchCustomStats(start, end));
  }

  Future<void> fetchBestSelling() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bestSelling = await _statisticService.fetchBestSelling();
    } catch (e) {
      _errorMessage = e.toString();
      _bestSelling = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New methods for fetching comparative revenue data
  Future<void> fetchAnnualRevenueComparison() async {
    await _fetchComparative(
      () => _statisticService.fetchAnnualRevenueComparison(),
      (data) => _annualRevenueComparison = data,
    );
  }

  Future<void> fetchQuarterlyRevenueComparison() async {
    await _fetchComparative(
      () => _statisticService.fetchQuarterlyRevenueComparison(),
      (data) => _quarterlyRevenueComparison = data,
    );
  }

  Future<void> fetchMonthlyRevenueComparison() async {
    await _fetchComparative(
      () => _statisticService.fetchMonthlyRevenueComparison(),
      (data) => _monthlyRevenueComparison = data,
    );
  }

  Future<void> fetchWeeklyRevenueComparison() async {
    await _fetchComparative(
      () => _statisticService.fetchWeeklyRevenueComparison(),
      (data) => _weeklyRevenueComparison = data,
    );
  }

  Future<void> _fetch(Future<MockDataDto> Function() fetchFunction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentStats = await fetchFunction();
    } catch (e) {
      _errorMessage = e.toString();
      _currentStats = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchComparative(
    Future<ComparativeRevenueDto> Function() fetchFunction,
    void Function(ComparativeRevenueDto) setData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await fetchFunction();
      setData(data);
    } catch (e) {
      _errorMessage = e.toString();
      setData(ComparativeRevenueDto(currentPeriod: [], previousPeriod: []));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStats() {
    _currentStats = null;
    _bestSelling = [];
    _payments = [];
    _annualRevenueComparison = null;
    _quarterlyRevenueComparison = null;
    _monthlyRevenueComparison = null;
    _weeklyRevenueComparison = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
