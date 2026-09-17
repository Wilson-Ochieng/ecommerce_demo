import 'package:flutter/foundation.dart';

import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  final NotificationService _notificationService;

  NotificationViewModel({
    NotificationRepository? repository,
    NotificationService? notificationService,
  }) : _repository = repository ?? NotificationRepository(),
       _notificationService = notificationService ?? NotificationService();

  bool _isLoading = false;
  String? _error;
  String? _fcmToken;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get fcmToken => _fcmToken;

  Future<void> initializeNotifications({required String uid}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await _notificationService.initialize();

      if (token != null && token.isNotEmpty) {
        _fcmToken = token;

        await _repository.saveFcmToken(uid: uid, token: token);
      }

      _notificationService.listenForTokenRefresh((newToken) async {
        _fcmToken = newToken;

        await _repository.saveFcmToken(uid: uid, token: newToken);

        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      debugPrint('Notification initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeToken({required String uid}) async {
    await _repository.removeFcmToken(uid: uid);

    _fcmToken = null;
    notifyListeners();
  }
}
