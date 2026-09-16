import 'dart:convert';

import 'package:http/http.dart' as http;

class MpesaRepository {
static const String _baseUrl =
'https://mpesa-payment-server-g9rk.onrender.com';

// ----------------------------------------------------------
// M-PESA STK PUSH
// ----------------------------------------------------------

Future<MpesaResponse> stkPush({
required String phoneNumber,
required double amount,
required String orderId,
required String customerName,
required String customerEmail,
}) async {
try {
final response = await http.post(
Uri.parse(
'$_baseUrl/api/payments/mpesa/stk-push',
),
headers: {
'Content-Type': 'application/json',
},
body: jsonEncode({
'phoneNumber': phoneNumber,
'amount': amount,
'orderId': orderId,
'customerName': customerName,
'customerEmail': customerEmail,
}),
);

final data = jsonDecode(response.body);

// ------------------------------------------------------
// HTTP ERROR
// ------------------------------------------------------

if (response.statusCode < 200 ||
response.statusCode >= 300) {
return MpesaResponse(
success: false,
message:
data['message'] ??
'Failed to initiate M-Pesa payment.',
);
}

// ------------------------------------------------------
// BACKEND ERROR
// ------------------------------------------------------

if (data['success'] != true) {
return MpesaResponse(
success: false,
message:
data['message'] ??
'M-Pesa payment request failed.',
);
}

// ------------------------------------------------------
// SUCCESS
// ------------------------------------------------------

final paymentData =
data['data'] as Map<String, dynamic>?;

return MpesaResponse(
success: true,
message:
data['message'] ??
'STK Push sent successfully.',
checkoutRequestId:
paymentData?['checkoutRequestId'],
merchantRequestId:
paymentData?['merchantRequestId'],
);
} catch (e) {
return MpesaResponse(
success: false,
message:
'Unable to connect to the payment server.',
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
final response = await http.get(
Uri.parse(
'$_baseUrl/api/payments/mpesa/status/$checkoutRequestId',
),
);

final data = jsonDecode(response.body);

// ------------------------------------------------------
// PAYMENT NOT FOUND / SERVER ERROR
// ------------------------------------------------------

if (response.statusCode != 200 ||
data['success'] != true) {
return MpesaPaymentStatus(
status: 'unknown',
message:
data['message'] ??
'Unable to check payment status.',
);
}

// ------------------------------------------------------
// PAYMENT DATA
// ------------------------------------------------------

final payment =
data['data'] as Map<String, dynamic>?;

final status =
payment?['status']?.toString() ??
'unknown';

final message =
payment?['message']?.toString() ??
'';

return MpesaPaymentStatus(
status: status,
message: message,
);
} catch (e) {
return MpesaPaymentStatus(
status: 'unknown',
message:
'Unable to check payment status.',
);
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

MpesaPaymentStatus({
required this.status,
required this.message,
});

bool get isSuccessful =>
status.toLowerCase() == 'paid';

bool get isFailed =>
status.toLowerCase() == 'failed';
}
