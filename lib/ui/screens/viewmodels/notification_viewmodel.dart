import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? orderId;
  final String? receiptNumber;
  final DateTime? createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    this.receiptNumber,
    this.createdAt,
    this.read = false,
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final timestamp = data['createdAt'];

    return NotificationModel(
      id: document.id,
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      orderId: data['orderId']?.toString(),
      receiptNumber: data['receiptNumber']?.toString(),
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
      read: data['read'] == true,
    );
  }
}