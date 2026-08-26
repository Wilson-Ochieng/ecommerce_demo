import 'package:flutter/material.dart';
import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/data/repositories/auth_repository.dart';


class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterViewModel({
    AuthRepository? authRepository,
  }) : _authRepository =
            authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UserModel? get user => _user;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
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

  String _handleError(Object error) {
    final message = error.toString();

    if (message.contains(
      'email-already-in-use',
    )) {
      return 'An account already exists with this email.';
    }

    if (message.contains(
      'invalid-email',
    )) {
      return 'Please enter a valid email address.';
    }

    if (message.contains(
      'weak-password',
    )) {
      return 'Password is too weak.';
    }

    if (message.contains(
      'permission-denied',
    )) {
      return 'Account created, but your Firestore profile could not be created. Check Firestore rules.';
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }
}