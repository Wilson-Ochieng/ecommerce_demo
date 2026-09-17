import 'package:flutter/foundation.dart';

import '../../../data/repositories/mpesa_repository.dart';
import 'cart_viewmodel.dart';

enum PaymentMethod { mpesa, cash }

class CheckoutViewModel extends ChangeNotifier {
  final MpesaRepository _mpesaRepository;

  CheckoutViewModel({MpesaRepository? mpesaRepository})
    : _mpesaRepository = mpesaRepository ?? MpesaRepository();

  PaymentMethod _paymentMethod = PaymentMethod.mpesa;

  bool _isLoading = false;
  String _message = '';

  String? _checkoutRequestId;

  PaymentMethod get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String get message => _message;
  String? get checkoutRequestId => _checkoutRequestId;

  // ----------------------------------------------------------
  // SELECT PAYMENT METHOD
  // ----------------------------------------------------------

  void selectPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    _message = '';
    notifyListeners();
  }

  // ----------------------------------------------------------
  // CHECKOUT
  // ----------------------------------------------------------

  Future<bool> checkout({
    required CartViewModel cart,
    required String phoneNumber,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerUid,
  }) async {
    // --------------------------------------------------------
    // CART VALIDATION
    // --------------------------------------------------------

    if (cart.isEmpty) {
      _message = 'Your cart is empty.';
      notifyListeners();
      return false;
    }

    // --------------------------------------------------------
    // ORDER ID VALIDATION
    // --------------------------------------------------------

    if (orderId.trim().isEmpty) {
      _message = 'Order ID is required.';
      notifyListeners();
      return false;
    }

    // --------------------------------------------------------
    // CUSTOMER NAME VALIDATION
    // --------------------------------------------------------

    if (customerName.trim().isEmpty) {
      _message = 'Customer name is required.';
      notifyListeners();
      return false;
    }

    // --------------------------------------------------------
    // CUSTOMER EMAIL VALIDATION
    // --------------------------------------------------------

    if (customerEmail.trim().isEmpty) {
      _message = 'Customer email is required.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _message = '';
    _checkoutRequestId = null;

    notifyListeners();

    try {
      // ------------------------------------------------------
      // CASH PAYMENT
      // ------------------------------------------------------

      if (_paymentMethod == PaymentMethod.cash) {
        _message = 'Order ready. Payment will be made in cash.';

        return true;
      }

      // ------------------------------------------------------
      // M-PESA PHONE VALIDATION
      // ------------------------------------------------------

      final phone = phoneNumber.trim();

      if (phone.isEmpty) {
        _message = 'Please enter your M-Pesa phone number.';

        return false;
      }

      if (!RegExp(r'^2547\d{8}$').hasMatch(phone)) {
        _message = 'Enter a valid M-Pesa number e.g. 254712345678.';

        return false;
      }

      // ------------------------------------------------------
      // M-PESA STK PUSH
      // ------------------------------------------------------

      _message = 'Sending M-Pesa payment request...';

      notifyListeners();

      final response = await _mpesaRepository.stkPush(
        phoneNumber: phone,
        amount: cart.total,
        orderId: orderId.trim(),
        customerName: customerName.trim(),
        customerEmail: customerEmail.trim(),
        customerUid: customerUid.trim(),
      );

      // ------------------------------------------------------
      // STK PUSH FAILED
      // ------------------------------------------------------

      if (!response.success) {
        _message = response.message.isNotEmpty
            ? response.message
            : 'Failed to initiate M-Pesa payment.';

        return false;
      }

      // ------------------------------------------------------
      // SAVE CHECKOUT REQUEST ID
      // ------------------------------------------------------

      _checkoutRequestId = response.checkoutRequestId;

      if (_checkoutRequestId == null || _checkoutRequestId!.isEmpty) {
        _message = 'M-Pesa checkout request was not created.';

        return false;
      }

      // ------------------------------------------------------
      // WAIT FOR M-PESA PAYMENT CONFIRMATION
      // ------------------------------------------------------

      _message = 'STK Push sent. Please enter your M-Pesa PIN on your phone.';

      notifyListeners();

      final paymentSuccessful = await _waitForPaymentConfirmation(
        _checkoutRequestId!,
      );

      // ------------------------------------------------------
      // PAYMENT NOT CONFIRMED
      // ------------------------------------------------------

      if (!paymentSuccessful) {
        _message = 'M-Pesa payment was not completed or timed out.';

        return false;
      }

      // ------------------------------------------------------
      // PAYMENT CONFIRMED
      // ------------------------------------------------------

      _message = 'M-Pesa payment confirmed successfully.';

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Checkout error: $e');

      _message = 'Payment failed. Please try again.';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // WAIT FOR M-PESA PAYMENT CONFIRMATION
  // ----------------------------------------------------------

  Future<bool> _waitForPaymentConfirmation(String checkoutRequestId) async {
    const maxAttempts = 12;
    const delay = Duration(seconds: 5);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final result = await _mpesaRepository.checkPaymentStatus(
          checkoutRequestId,
        );

        debugPrint(
          'M-Pesa status attempt '
          '${attempt + 1}: ${result.status}',
        );

        // ----------------------------------------------------
        // PAYMENT SUCCESSFUL
        // ----------------------------------------------------

        if (result.isSuccessful) {
          return true;
        }

        // ----------------------------------------------------
        // PAYMENT FAILED
        // ----------------------------------------------------

        if (result.isFailed) {
          return false;
        }
      } catch (e) {
        debugPrint('Payment status check error: $e');
      }

      // ------------------------------------------------------
      // WAIT BEFORE NEXT CHECK
      // ------------------------------------------------------

      if (attempt < maxAttempts - 1) {
        await Future.delayed(delay);
      }
    }

    // --------------------------------------------------------
    // PAYMENT TIMEOUT
    // --------------------------------------------------------

    return false;
  }
}
