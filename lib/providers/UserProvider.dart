import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  static const String _userKey = 'current_user';

  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  String? get userId => _user?.uid;

  String? get username => _user?.name;

  String? get email => _user?.email;

  String? get role => _user?.role;

  Future<void> saveUser(UserModel user) async {
    _user = user;

    final preferences = await SharedPreferences.getInstance();

    final userJson = jsonEncode(user.toMap());

    await preferences.setString(_userKey, userJson);

    notifyListeners();
  }

  Future<void> loadUser() async {
    final preferences = await SharedPreferences.getInstance();

    final userJson = preferences.getString(_userKey);

    if (userJson == null) {
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(userJson);

      _user = UserModel.fromMap(data);
    } catch (e) {
      _user = null;

      await preferences.remove(_userKey);
    }

    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;

    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_userKey);

    notifyListeners();
  }
}
