import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/mpesa_repository.dart';
import '../../../data/models/payment_model.dart';

import '../viewmodels/cart_viewmodel.dart';

enum PaymentMethod { mpesa, cash }

class CheckoutViewModel extends ChangeNotifier {
  final MpesaRepository _mpesaRepository;

  CheckoutViewModel({MpesaRepository? mpesaRepository})
    : _mpesaRepository = mpesaRepository ?? MpesaRepository();

  PaymentMethod _paymentMethod = PaymentMethod.mpesa;

  PaymentMethod get paymentMethod => _paymentMethod;

  String _message = '';

  String get message => _message;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  PaymentModel? _payment;

  PaymentModel? get payment => _payment;

  Timer? _statusTimer;

  void selectPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    _message = '';
    notifyListeners();
  }

  Future<void> checkout({
    required CartViewModel cart,
    required String phoneNumber,
  }) async {
    if (cart.isEmpty) {
      _message = 'Your cart is empty.';
      notifyListeners();
      return;
    }

    if (_paymentMethod == PaymentMethod.cash) {
      await _processCash(cart);
      return;
    }

    await _processMpesa(cart: cart, phoneNumber: phoneNumber);
  }

  Future<void> _processCash(CartViewModel cart) async {
    _isLoading = true;
    _message = 'Processing cash payment...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;

    _message = 'Order placed successfully. Payment will be made in cash.';

    notifyListeners();
  }

  Future<void> _processMpesa({
    required CartViewModel cart,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _message = 'Sending M-Pesa payment request...';
    notifyListeners();

    try {
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      final result = await _mpesaRepository.initiatePayment(
        phoneNumber: phoneNumber,
        amount: cart.total,
        orderId: orderId,
      );

      final data = Map<String, dynamic>.from(result['data']);

      final checkoutRequestId = data['checkoutRequestId'];

      if (checkoutRequestId == null) {
        _isLoading = false;
        _message = result['message'] ?? 'Unable to initiate payment.';
        notifyListeners();
        return;
      }

      _message =
          data['customerMessage'] ?? 'STK Push sent. Enter your M-Pesa PIN.';

      notifyListeners();

      _startPaymentStatusPolling(checkoutRequestId);
    } catch (e) {
      _isLoading = false;
      _message = 'Unable to initiate M-Pesa payment. Please try again.';
      notifyListeners();
    }
  }

  void _startPaymentStatusPolling(String checkoutRequestId) {
    _statusTimer?.cancel();

    int attempts = 0;

    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;

      if (attempts > 20) {
        timer.cancel();

        _isLoading = false;
        _message =
            'Payment confirmation timed out. Please check your M-Pesa messages.';

        notifyListeners();
        return;
      }

      try {
        final payment = await _mpesaRepository.checkPaymentStatus(
          checkoutRequestId,
        );

        _payment = payment;

        if (payment.isPaid) {
          timer.cancel();

          _isLoading = false;
          _message = payment.message;

          notifyListeners();

          return;
        }

        if (payment.isFailed) {
          timer.cancel();

          _isLoading = false;
          _message = payment.message;

          notifyListeners();

          return;
        }
      } catch (e) {
        // Continue polling.
      }
    });
  }

  void disposePolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
