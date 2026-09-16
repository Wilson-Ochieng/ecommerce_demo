import 'package:flutter/material.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/data/repositories/order_repository.dart';
import 'package:test_app/data/repositories/email_repository.dart';

class AdminOrdersViewModel extends ChangeNotifier {
  final OrderRepository _repository;
  final EmailRepository _emailRepository;

  AdminOrdersViewModel({
    OrderRepository? repository,
    EmailRepository? emailRepository,
  }) : _repository = repository ?? OrderRepository(),
       _emailRepository = emailRepository ?? EmailRepository();

  List<OrderModel> _orders = [];

  bool _isLoading = false;
  bool _isDispatching = false;

  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool get isLoading => _isLoading;

  bool get isDispatching => _isDispatching;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => _orders.isEmpty;

  // ============================================================
  // LOAD ALL ORDERS
  // ============================================================

  Future<void> loadOrders() async {
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

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadOrders();
  }

  // ============================================================
  // GET ORDER
  // ============================================================

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================

  Future<bool> updateOrderStatus({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    try {
      _errorMessage = null;

      await _repository.updateOrderStatus(
        userId: userId,
        orderId: orderId,
        orderStatus: status,
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
          orderStatus: status,
          createdAt: existingOrder.createdAt,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('UPDATE ORDER STATUS ERROR: $e');

      _errorMessage = 'Failed to update order status.\n$e';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // DISPATCH ORDER + SEND EMAIL
  // ============================================================

  Future<bool> dispatchOrder(OrderModel order) async {
    if (_isDispatching) {
      return false;
    }

    _isDispatching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // ========================================================
      // STEP 1
      // Send dispatch notification through Render
      // ========================================================

      await _emailRepository.sendOrderDispatchedEmail(
        customerName: order.customerName,
        customerEmail: order.customerEmail,
        orderId: order.id,
        total: order.total,
      );

      // ========================================================
      // STEP 2
      // Only mark as dispatched after email succeeds
      // ========================================================

      await _repository.updateOrderStatus(
        userId: order.userId,
        orderId: order.id,
        orderStatus: 'dispatched',
      );

      // ========================================================
      // STEP 3
      // Update local state
      // ========================================================

      final index = _orders.indexWhere((item) => item.id == order.id);

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
          orderStatus: 'dispatched',
          createdAt: existingOrder.createdAt,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('DISPATCH ORDER ERROR: $e');

      _errorMessage = 'Failed to dispatch order.\n$e';

      return false;
    } finally {
      _isDispatching = false;

      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE PAYMENT STATUS
  // ============================================================

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

      _errorMessage = 'Failed to update payment status.\n$e';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}
