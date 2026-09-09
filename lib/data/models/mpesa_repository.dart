import 'package:dio/dio.dart';

import '../models/payment_model.dart';

class MpesaRepository {
  final Dio _dio;

  MpesaRepository({Dio? dio}) : _dio = dio ?? Dio();

  static const String baseUrl =
      'https://mpesa-payment-server-g9rk.onrender.com';

  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String orderId,
  }) async {
    final response = await _dio.post(
      '$baseUrl/api/payments/mpesa/stk-push',
      data: {'phoneNumber': phoneNumber, 'amount': amount, 'orderId': orderId},
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<PaymentModel> checkPaymentStatus(String checkoutRequestId) async {
    final response = await _dio.get(
      '$baseUrl/api/payments/mpesa/status/$checkoutRequestId',
    );

    final data = Map<String, dynamic>.from(response.data['data']);

    return PaymentModel.fromJson(data);
  }
}
