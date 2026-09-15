import 'package:flutter/cupertino.dart';

import '../../../data/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserModel? _user;

  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasUser => _user != null;

  Future<void> loadProfile(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = user;
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
