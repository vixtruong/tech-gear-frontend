import 'package:dio/dio.dart';
import 'package:techgear/models/order/coupon.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/dio_client.dart';

class CouponService {
  final String apiUrl = '/api/v1/coupons';
  final DioClient _dioClient;

  CouponService(SessionProvider sessionProvider)
      : _dioClient = DioClient(sessionProvider);

  Future<List<Coupon>> getAllCoupons() async {
    try {
      final response = await _dioClient.instance.get(apiUrl);
      final data = response.data as List;
      return data.map((json) => Coupon.fromJson(json)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Get all coupons failed: $msg');
    }
  }

  Future<Coupon?> getCouponByCode(String code) async {
    try {
      final response = await _dioClient.instance.get('$apiUrl/$code');
      return Coupon.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Get coupon failed: $msg');
    }
  }

  Future<bool> createCoupon(Coupon coupon) async {
    try {
      final response = await _dioClient.instance.post(
        '$apiUrl/create',
        data: coupon.toJson(),
      );
      return response.statusCode == 201;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Create coupon failed: $msg');
    }
  }

  Future<bool> updateCoupon(Coupon coupon) async {
    try {
      final response = await _dioClient.instance.put(
        '$apiUrl/update',
        data: coupon.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Update coupon failed: $msg');
    }
  }

  Future<bool> deleteCoupon(int id) async {
    try {
      final response = await _dioClient.instance.delete('$apiUrl/delete/$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Update coupon failed: $msg');
    }
  }

  Future<bool> removeCouponUsage(String code) async {
    try {
      final response =
          await _dioClient.instance.delete('$apiUrl/remove-usage/$code');
      return response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Unknown error';
      throw Exception('Remove coupon usage failed: $msg');
    }
  }
}
