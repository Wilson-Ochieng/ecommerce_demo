import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('Background notification received: ${message.messageId}');

  debugPrint('Notification title: ${message.notification?.title}');

  debugPrint('Notification body: ${message.notification?.body}');

  debugPrint('Notification data: ${message.data}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'payment_notifications',
    'Payment Notifications',
    description: 'Notifications for payment and order updates.',
    importance: Importance.max,
    playSound: true,
  );

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<String?> initialize() async {
    try {
      // ----------------------------------------------------------
      // Request Firebase notification permission
      // ----------------------------------------------------------

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

      // ----------------------------------------------------------
      // Initialize local notifications
      // ----------------------------------------------------------

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
            'Notification tapped: '
            '${response.payload}',
          );
        },
      );

      // ----------------------------------------------------------
      // Create Android notification channel
      // ----------------------------------------------------------

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(_channel);

      // ----------------------------------------------------------
      // FCM token
      // ----------------------------------------------------------

      final token = await _messaging.getToken();

      debugPrint('FCM Token: $token');

      return token;
    } catch (e, stackTrace) {
      debugPrint('FCM initialization error: $e');

      debugPrint(stackTrace.toString());

      return null;
    }
  }

  // ============================================================
  // TOKEN REFRESH
  // ============================================================

  void listenForTokenRefresh(void Function(String token) onTokenRefresh) {
    _messaging.onTokenRefresh.listen(onTokenRefresh);
  }

  // ============================================================
  // FOREGROUND MESSAGES
  // ============================================================

  void listenForForegroundMessages(
    void Function(RemoteMessage message) onMessage,
  ) {
    debugPrint('FCM FOREGROUND LISTENER REGISTERED');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('FCM FOREGROUND MESSAGE RECEIVED');

      debugPrint('Title: ${message.notification?.title}');

      debugPrint('Body: ${message.notification?.body}');

      debugPrint('Data: ${message.data}');

      onMessage(message);

      await _showLocalNotification(message);
    });
  }

  // ============================================================
  // SHOW LOCAL NOTIFICATION
  // ============================================================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      debugPrint('No notification payload found.');

      return;
    }

    final androidNotification = notification.android;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'Duka Letu',
      body: notification.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,

          importance: Importance.max,

          priority: Priority.high,

          playSound: true,

          icon: androidNotification?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.toString(),
    );
  }

  // ============================================================
  // NOTIFICATION TAP
  // ============================================================

  void listenForNotificationTap(
    void Function(RemoteMessage message) onMessage,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessage);
  }

  // ============================================================
  // TERMINATED APP
  // ============================================================

  Future<RemoteMessage?> getInitialMessage() async {
    return _messaging.getInitialMessage();
  }
}
