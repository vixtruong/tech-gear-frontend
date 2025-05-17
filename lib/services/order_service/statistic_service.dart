import 'package:dio/dio.dart';
import 'package:techgear/dtos/mock_data_dto.dart';
import 'package:techgear/dtos/best_selling_dto.dart';
import 'package:techgear/dtos/payment_dto.dart';
import 'package:techgear/dtos/comparative_revenue_dto.dart'; // Import DTO mới
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class StatisticService {
  final String apiUrl = '/api/v1/statistics';
  final DioClient _dioClient;

  StatisticService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<PaymentDto>> fetchPayments() async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/payments');
      final List data = response.data;

      return data.map((item) => PaymentDto.fromJson(item)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<MockDataDto> fetchAnnualStats() async {
    return _fetchStatData('$apiUrl/annual');
  }

  Future<MockDataDto> fetchQuarterStats() async {
    return _fetchStatData('$apiUrl/quarter');
  }

  Future<MockDataDto> fetchMonthlyStats() async {
    return _fetchStatData('$apiUrl/month');
  }

  Future<MockDataDto> fetchWeeklyStats() async {
    return _fetchStatData('$apiUrl/week');
  }

  Future<MockDataDto> fetchCustomStats(DateTime start, DateTime end) async {
    try {
      final response = await _dioClient.instance.get(
        '$apiUrl/custom',
        queryParameters: {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );
      return MockDataDto.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to load custom stats';
      throw Exception(msg);
    }
  }

  Future<List<BestSellingDto>> fetchBestSelling() async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/best-selling');
      final List data = response.data;
      return data.map((e) => BestSellingDto.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? 'Failed to load best-selling data';
      throw Exception(msg);
    }
  }

  // New methods for comparative revenue
  Future<ComparativeRevenueDto> fetchAnnualRevenueComparison() async {
    return _fetchComparativeData('$apiUrl/annual-comparison');
  }

  Future<ComparativeRevenueDto> fetchQuarterlyRevenueComparison() async {
    return _fetchComparativeData('$apiUrl/quarter-comparison');
  }

  Future<ComparativeRevenueDto> fetchMonthlyRevenueComparison() async {
    return _fetchComparativeData('$apiUrl/month-comparison');
  }

  Future<ComparativeRevenueDto> fetchWeeklyRevenueComparison() async {
    return _fetchComparativeData('$apiUrl/week-comparison');
  }

  Future<MockDataDto> _fetchStatData(String url) async {
    try {
      final response = await _dioClient.instance.get(url);
      return MockDataDto.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Failed to load statistics';
      throw Exception(msg);
    }
  }

  Future<ComparativeRevenueDto> _fetchComparativeData(String url) async {
    try {
      final response = await _dioClient.instance.get(url);
      return ComparativeRevenueDto.fromJson(response.data);
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? 'Failed to load comparative data';
      throw Exception(msg);
    }
  }
}
