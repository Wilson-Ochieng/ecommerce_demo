import 'package:flutter/foundation.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class UserManagementViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserManagementViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Stream<List<UserModel>> get users {
    return _authRepository.getUsers();
  }

  Future<bool> changeRole({required String uid, required String role}) async {
    _setLoading(true);

    try {
      await _authRepository.updateUserRole(uid: uid, role: role);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(String uid) async {
    _setLoading(true);

    try {
      await _authRepository.deleteUserProfile(uid);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _handleError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
