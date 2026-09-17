class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? orderId;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    required this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'orderId': orderId,
      'createdAt': createdAt,
      'read': read,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      orderId: map['orderId'],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.now(),
      read: map['read'] ?? false,
    );
  }
}
