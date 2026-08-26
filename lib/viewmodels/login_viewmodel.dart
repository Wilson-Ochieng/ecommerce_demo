import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _loginSuccessful = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get loginSuccessful => _loginSuccessful;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _loginSuccessful = false;

    notifyListeners();

    try {
      await _authRepository.login(
        email: email,
        password: password,
      );

      _loginSuccessful = true;

      return true;
    } catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getFirebaseErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }

    if (message.contains('user-not-found')) {
      return 'No account exists with this email.';
    }

    if (message.contains('wrong-password')) {
      return 'Incorrect password.';
    }

    if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }

    return 'Login failed. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}