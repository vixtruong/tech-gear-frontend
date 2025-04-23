import 'package:flutter/material.dart';
import 'package:techgear/models/order/coupon.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/order_service/coupon_service.dart';

class CouponProvider with ChangeNotifier {
  final CouponService _couponService;
  List<Coupon> _coupons = [];
  bool _isLoading = false;
  String? _error;

  CouponProvider(SessionProvider sessionProvider)
      : _couponService = CouponService(sessionProvider);

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await _couponService.getAllCoupons();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Coupon? getCouponByCode(String code) {
    try {
      return _coupons.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createCoupon(Coupon coupon) async {
    try {
      final result = await _couponService.createCoupon(coupon);
      if (result) await fetchCoupons();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCoupon(Coupon coupon) async {
    try {
      final result = await _couponService.updateCoupon(coupon);
      if (result) await fetchCoupons();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ✅ Áp dụng / trừ lượt dùng coupon
  Future<bool> removeCouponUsage(String code) async {
    try {
      final result = await _couponService.removeCouponUsage(code);
      if (result) await fetchCoupons();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
