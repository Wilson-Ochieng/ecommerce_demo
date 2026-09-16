import 'package:flutter/foundation.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/data/repositories/order_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrderRepository _repository;

  OrdersViewModel({OrderRepository? repository})
    : _repository = repository ?? OrderRepository();

  List<OrderModel> _orders = [];

  bool _isLoading = false;

  String? _errorMessage;

  // ==========================================================
  // GETTERS
  // ==========================================================

  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => _orders.isEmpty;

  // ==========================================================
  // CUSTOMER - LOAD MY ORDERS
  // ==========================================================

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _orders = await _repository.getUserOrders(userId);
    } catch (e) {
      debugPrint('CUSTOMER ORDERS ERROR: $e');

      _errorMessage = 'Failed to load your orders.\n$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // ADMIN - LOAD ALL ORDERS
  // ==========================================================

  Future<void> loadAllOrders() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _orders = await _repository.getAllOrders();
    } catch (e) {
      debugPrint('ADMIN ORDERS ERROR: $e');

      _errorMessage = 'Failed to load orders.\n$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // REFRESH CUSTOMER ORDERS
  // ==========================================================

  Future<void> refreshOrders(String userId) async {
    await loadOrders(userId);
  }

  // ==========================================================
  // REFRESH ADMIN ORDERS
  // ==========================================================

  Future<void> refreshAllOrders() async {
    await loadAllOrders();
  }

  // ==========================================================
  // GET ORDER BY ID
  // ==========================================================

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // CREATE ORDER
  // ==========================================================

  Future<String?> createOrder({
    required String userId,
    required OrderModel order,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final orderId = await _repository.createOrder(
        userId: userId,
        order: order,
      );

      if (orderId == null || orderId.isEmpty) {
        _errorMessage = 'Order was not created.';

        return null;
      }

      return orderId;
    } catch (e) {
      debugPrint('CREATE ORDER ERROR: $e');

      _errorMessage = 'Failed to create order.';

      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // UPDATE PAYMENT STATUS
  // ==========================================================

  Future<bool> updatePaymentStatus({
    required String userId,
    required String orderId,
    required String paymentStatus,
    required String orderStatus,
  }) async {
    try {
      _errorMessage = null;

      await _repository.updatePaymentStatus(
        userId: userId,
        orderId: orderId,
        paymentStatus: paymentStatus,
        orderStatus: orderStatus,
      );

      final index = _orders.indexWhere((order) => order.id == orderId);

      if (index != -1) {
        final existingOrder = _orders[index];

        _orders[index] = OrderModel(
          id: existingOrder.id,
          userId: existingOrder.userId,
          customerName: existingOrder.customerName,
          customerEmail: existingOrder.customerEmail,
          items: existingOrder.items,
          total: existingOrder.total,
          paymentMethod: existingOrder.paymentMethod,
          paymentStatus: paymentStatus,
          orderStatus: orderStatus,
          createdAt: existingOrder.createdAt,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('UPDATE PAYMENT STATUS ERROR: $e');

      _errorMessage = 'Failed to update payment status.';

      notifyListeners();

      return false;
    }
  }

  // ==========================================================
  // UPDATE ORDER STATUS
  // ==========================================================

  Future<bool> updateOrderStatus({
    required String userId,
    required String orderId,
    required String orderStatus,
  }) async {
    try {
      _errorMessage = null;

      await _repository.updateOrderStatus(
        userId: userId,
        orderId: orderId,
        orderStatus: orderStatus,
      );

      final index = _orders.indexWhere((order) => order.id == orderId);

      if (index != -1) {
        final existingOrder = _orders[index];

        _orders[index] = OrderModel(
          id: existingOrder.id,
          userId: existingOrder.userId,
          customerName: existingOrder.customerName,
          customerEmail: existingOrder.customerEmail,
          items: existingOrder.items,
          total: existingOrder.total,
          paymentMethod: existingOrder.paymentMethod,
          paymentStatus: existingOrder.paymentStatus,
          orderStatus: orderStatus,
          createdAt: existingOrder.createdAt,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('UPDATE ORDER STATUS ERROR: $e');

      _errorMessage = 'Failed to update order status.';

      notifyListeners();

      return false;
    }
  }

  // ==========================================================
  // CLEAR ERROR
  // ==========================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
