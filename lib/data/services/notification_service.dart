import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print(
    'Background notification received: '
    '${message.messageId}',
  );

  print(
    'Notification title: '
    '${message.notification?.title}',
  );

  print(
    'Notification body: '
    '${message.notification?.body}',
  );

  print(
    'Notification data: '
    '${message.data}',
  );
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request permission and retrieve the FCM token.
  Future<String?> initialize() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        'Notification permission status: '
        '${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notification permission denied.');
        return null;
      }

      final token = await _messaging.getToken();

      debugPrint('FCM Token: $token');

      return token;
    } catch (e) {
      debugPrint('FCM initialization error: $e');

      return null;
    }
  }

  /// Listen for changes to the FCM registration token.
  void listenForTokenRefresh(void Function(String token) onTokenRefresh) {
    _messaging.onTokenRefresh.listen(onTokenRefresh);
  }

  /// Listen for notifications while the app
  /// is open in the foreground.
  void listenForForegroundMessages(
    void Function(RemoteMessage message) onMessage,
  ) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Handle a notification that opened the app
  /// from the background.
  void listenForNotificationTap(
    void Function(RemoteMessage message) onMessage,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessage);
  }

  /// Check whether the app was opened by tapping
  /// a notification while the app was terminated.
  Future<RemoteMessage?> getInitialMessage() async {
    return _messaging.getInitialMessage();
  }
}
