import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterViewModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _registrationSuccessful = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get registrationSuccessful => _registrationSuccessful;

  Future<bool> register({
    required String email,
    required String password, required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _registrationSuccessful = false;

    notifyListeners();

    try {
      await _authRepository.register(
        email: email,
        password: password, name: '',
      );

      _registrationSuccessful = true;

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

    if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }

    if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('weak-password')) {
      return 'The password is too weak.';
    }

    if (message.contains('operation-not-allowed')) {
      return 'Email and password authentication is not enabled.';
    }

    return 'Registration failed. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}