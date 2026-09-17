
import 'package:flutter/material.dart';
import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/data/repositories/auth_repository.dart';

import '../../../data/services/notification_service.dart';

class LoginViewModel extends ChangeNotifier {
final AuthRepository _authRepository;
final NotificationService _notificationService;

LoginViewModel({
AuthRepository? authRepository,
NotificationService? notificationService,
}) : _authRepository = authRepository ?? AuthRepository(),
_notificationService =
notificationService ?? NotificationService();

bool _isLoading = false;
String? _errorMessage;
UserModel? _user;

bool get isLoading => _isLoading;

String? get errorMessage => _errorMessage;

UserModel? get user => _user;

Future<bool> login({
required String email,
required String password,
}) async {
_isLoading = true;
_errorMessage = null;

notifyListeners();

try {
// ========================================================
// LOGIN
// ========================================================

_user = await _authRepository.login(
email: email,
password: password,
);

// ========================================================
// INITIALIZE FCM
// ========================================================

final token = await _notificationService.initialize();

if (token != null && token.isNotEmpty) {
try {
await _authRepository.updateFcmToken(
uid: _user!.uid,
token: token,
);

debugPrint(
'FCM token saved for user ${_user!.uid}',
);
} catch (e) {
// Notification registration should NOT
// make a successful login fail.
debugPrint(
'Failed to save FCM token: $e',
);
}
}

// ========================================================
// LISTEN FOR TOKEN REFRESH
// ========================================================

_notificationService.listenForTokenRefresh(
(newToken) async {
try {
await _authRepository.updateFcmToken(
uid: _user!.uid,
token: newToken,
);

debugPrint(
'FCM token refreshed for user ${_user!.uid}',
);
} catch (e) {
debugPrint(
'Failed to update refreshed FCM token: $e',
);
}
},
);

return true;
} catch (e) {
_errorMessage = _handleError(e);

return false;
} finally {
_isLoading = false;

notifyListeners();
}
}

Future<bool> resendVerificationEmail() async {
_isLoading = true;
_errorMessage = null;

notifyListeners();

try {
await _authRepository.resendVerificationEmail();

return true;
} catch (e) {
_errorMessage = _handleError(e);

return false;
} finally {
_isLoading = false;

notifyListeners();
}
}

String _handleError(Object error) {
final message = error.toString();

if (message.contains('invalid-credential')) {
return 'Incorrect email or password.';
}

if (message.contains('user-not-found')) {
return 'No account exists with this email.';
}

if (message.contains('wrong-password')) {
return 'Incorrect email or password.';
}

if (message.contains('verify your email')) {
return 'Please verify your email before logging in.';
}

if (message.contains('User profile does not exist')) {
return 'Your account exists, but your Firestore profile is missing.';
}

return message.replaceFirst('Exception: ', '');
}
}

