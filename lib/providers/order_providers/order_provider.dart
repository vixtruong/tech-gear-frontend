import 'package:flutter/material.dart';
import 'package:techgear/dtos/order_dto.dart';
import 'package:techgear/providers/auth_providers/session_provider.dart';
import 'package:techgear/services/order_service/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  // ignore: unused_field
  final SessionProvider _sessionProvider;

  OrderProvider(this._sessionProvider)
      : _orderService = OrderService(_sessionProvider);

  List<OrderDto> _orders = [];
  List<OrderDto> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _orderSuccess = false;
  bool get orderSuccess => _orderSuccess;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrdersByUserId(int userId) async {
    try {
      final data = await _orderService.fetchOrdersByUserId(userId);
      _orders = data.map((item) => OrderDto.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Tạo đơn hàng mới
  Future<void> createOrder(OrderDto order) async {
    _isLoading = true;
    _errorMessage = null;
    _orderSuccess = false;
    notifyListeners();

    try {
      final success = await _orderService.createOrder(order);
      _orderSuccess = success;
    } catch (e) {
      _errorMessage = e.toString();
      _orderSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset lại trạng thái sau khi tạo đơn hàng xong
  void resetOrderStatus() {
    _orderSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }
}
