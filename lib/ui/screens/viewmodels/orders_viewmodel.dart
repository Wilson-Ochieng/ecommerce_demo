import 'package:flutter/material.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/data/repositories/order_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrderRepository _repository;

  OrdersViewModel({OrderRepository? repository})
    : _repository = repository ?? OrderRepository();

  List<OrderModel> _orders = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => _orders.isEmpty;

  // ===========================================================
  // LOAD ORDERS
  // ===========================================================

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _orders = await _repository.getUserOrders(userId);
    } catch (e) {
      _errorMessage = 'Failed to load your orders.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // REFRESH
  // ===========================================================

  Future<void> refreshOrders(String userId) async {
    await loadOrders(userId);
  }

  // ===========================================================
  // FIND ORDER
  // ===========================================================

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
