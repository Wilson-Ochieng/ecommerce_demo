import 'package:flutter/material.dart';

import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/data/repositories/auth_repository.dart';
import 'package:test_app/providers/UserProvider.dart';

class AuthStartupViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserProvider _userProvider;

  AuthStartupViewModel({
    AuthRepository? authRepository,
    UserProvider? userProvider,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _userProvider = userProvider ?? UserProvider();

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
      final user = await _authRepository.getCurrentUser();

      _user = user;

      if (user != null) {
        await _userProvider.saveUser(user);
      } else {
        await _userProvider.clearUser();
      }
    } catch (e) {
      _errorMessage = _handleError(e);
      _user = null;

      await _userProvider.clearUser();
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
      await _authRepository.logout();

      _user = null;

      await _userProvider.clearUser();

      return true;
    } catch (e) {
      _errorMessage = _handleError(e);

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _handleError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
