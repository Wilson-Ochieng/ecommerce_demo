import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailRepository {
  // ============================================================
  // RENDER API
  // ============================================================

  static const String _baseUrl =
      'https://mpesa-payment-server-g9rk.onrender.com';

  // ============================================================
  // SEND ORDER DISPATCH EMAIL
  // ============================================================

  Future<void> sendOrderDispatchedEmail({
    required String customerName,
    required String customerEmail,
    required String orderId,
    required double total,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/email/dispatch');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'customerName': customerName,
          'customerEmail': customerEmail,
          'orderId': orderId,
          'total': total,
        }),
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      // ========================================================
      // SERVER ERROR
      // ========================================================

      String message = 'Failed to send dispatch email.';

      try {
        final data = jsonDecode(response.body);

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {
        // Ignore invalid JSON response.
      }

      throw Exception(
        '$message '
        '(HTTP ${response.statusCode})',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Unable to connect to email service.');
    }
  }
}
