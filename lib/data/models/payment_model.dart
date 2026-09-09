class PaymentModel {
  final String checkoutRequestId;
  final String orderId;
  final String status;
  final String message;
  final String? receiptNumber;

  PaymentModel({
    required this.checkoutRequestId,
    required this.orderId,
    required this.status,
    required this.message,
    this.receiptNumber,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      checkoutRequestId: json['checkoutRequestId'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
      receiptNumber: json['receiptNumber'],
    );
  }

  bool get isPending => status == 'pending';

  bool get isPaid => status == 'paid';

  bool get isFailed => status == 'failed';
}
