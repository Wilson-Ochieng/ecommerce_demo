import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MpesaRepository {
  static const String _baseUrl =
      'https://mpesa-payment-server-g9rk.onrender.com';

  static const Duration _requestTimeout = Duration(seconds: 30);

  // ----------------------------------------------------------
  // M-PESA STK PUSH
  // ----------------------------------------------------------

  Future<MpesaResponse> stkPush({
    required String phoneNumber,
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerUid,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/payments/mpesa/stk-push'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phoneNumber': phoneNumber,
              'amount': amount,
              'orderId': orderId,
              'customerName': customerName,
              'customerEmail': customerEmail,
              'customerUid': customerUid,
            }),
          )
          .timeout(_requestTimeout);

      final data = _safeDecode(response.body);

      if (data == null) {
        return MpesaResponse(
          success: false,
          message: 'Payment server returned an invalid response.',
        );
      }

      // ---- HTTP error ----

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MpesaResponse(
          success: false,
          message:
              (data['message'] as String?) ??
              'Failed to initiate M-Pesa payment.',
        );
      }

      // ---- Backend error ----

      if (data['success'] != true) {
        return MpesaResponse(
          success: false,
          message:
              (data['message'] as String?) ?? 'M-Pesa payment request failed.',
        );
      }

      // ---- Success ----

      final paymentData = data['data'] as Map<String, dynamic>?;

      return MpesaResponse(
        success: true,
        message: (data['message'] as String?) ?? 'STK Push sent successfully.',
        checkoutRequestId: paymentData?['checkoutRequestId'] as String?,
        merchantRequestId: paymentData?['merchantRequestId'] as String?,
      );
    } on TimeoutException {
      return MpesaResponse(
        success: false,
        message: 'Payment server timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('stkPush error: $e');
      return MpesaResponse(
        success: false,
        message: 'Unable to connect to the payment server.',
      );
    }
  }

  // ----------------------------------------------------------
  // CHECK PAYMENT STATUS
  // ----------------------------------------------------------

  Future<MpesaPaymentStatus> checkPaymentStatus(
    String checkoutRequestId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/payments/mpesa/status/$checkoutRequestId'),
          )
          .timeout(_requestTimeout);

      final data = _safeDecode(response.body);

      if (data == null) {
        return MpesaPaymentStatus(
          status: 'unknown',
          message: 'Payment server returned an invalid response.',
        );
      }

      if (response.statusCode != 200 || data['success'] != true) {
        return MpesaPaymentStatus(
          status: 'unknown',
          message:
              (data['message'] as String?) ?? 'Unable to check payment status.',
        );
      }

      final payment = data['data'] as Map<String, dynamic>?;
      final status = payment?['status']?.toString() ?? 'unknown';
      final message = payment?['message']?.toString() ?? '';

      return MpesaPaymentStatus(status: status, message: message);
    } on TimeoutException {
      return MpesaPaymentStatus(
        status: 'unknown',
        message: 'Payment status check timed out.',
      );
    } catch (e) {
      debugPrint('checkPaymentStatus error: $e');
      return MpesaPaymentStatus(
        status: 'unknown',
        message: 'Unable to check payment status.',
      );
    }
  }

  // ----------------------------------------------------------
  // SAFE JSON DECODE
  // ----------------------------------------------------------

  Map<String, dynamic>? _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (e) {
      debugPrint('JSON decode failed: $e');
      return null;
    }
  }
}

// ==========================================================
// M-PESA STK RESPONSE
// ==========================================================

class MpesaResponse {
  final bool success;
  final String message;
  final String? checkoutRequestId;
  final String? merchantRequestId;

  MpesaResponse({
    required this.success,
    required this.message,
    this.checkoutRequestId,
    this.merchantRequestId,
  });
}

// ==========================================================
// M-PESA PAYMENT STATUS
// ==========================================================

class MpesaPaymentStatus {
  final String status;
  final String message;

  MpesaPaymentStatus({required this.status, required this.message});

  String get _normalized => status.toLowerCase().trim();

  bool get isSuccessful => _normalized == 'paid';

  bool get isPending => _normalized == 'pending' || _normalized == 'unknown';

  bool get isFailed =>
      _normalized == 'failed' ||
      _normalized == 'cancelled' ||
      _normalized == 'canceled' ||
      _normalized == 'rejected' ||
      _normalized == 'timeout' ||
      _normalized == 'expired';

  /// True if we should stop polling and give up (success OR terminal failure).
  bool get isTerminal => !isPending;
}
