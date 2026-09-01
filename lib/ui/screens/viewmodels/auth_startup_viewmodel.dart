import 'package:flutter/material.dart';
import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/data/repositories/auth_repository.dart';

class AuthStartupViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStartupViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UserModel? get user => _user;

  bool get isAuthenticated => _user != null;

  bool get isAdmin => _user?.role == 'admin';

  bool get isCustomer => _user?.role == 'customer';

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _errorMessage = _handleError(e);
      _user = null;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // Sign out from Firebase
      await _authRepository.logout();

      // Clear UserModel from memory
      _user = null;

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
    return error.toString().replaceFirst('Exception: ', '');
  }
}
