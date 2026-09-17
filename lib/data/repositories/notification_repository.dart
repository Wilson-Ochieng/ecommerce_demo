import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  NotificationRepository({
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _notificationService = notificationService ?? NotificationService();

  Future<String?> initializeForUser({required String uid}) async {
    final token = await _notificationService.initialize();

    if (token == null || token.isEmpty) {
      return null;
    }

    await saveFcmToken(uid: uid, token: token);

    _notificationService.listenForTokenRefresh((newToken) async {
      await saveFcmToken(uid: uid, token: newToken);
    });

    return token;
  }

  Future<void> saveFcmToken({
    required String uid,
    required String token,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFcmToken({required String uid}) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmToken': FieldValue.delete(),
      'fcmTokenUpdatedAt': FieldValue.delete(),
    });
  }
}
