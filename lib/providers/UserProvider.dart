import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  static const String _userKey = 'logged_in_user';

  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  String? get uid => _user?.uid;

  String? get name => _user?.name;

  String? get email => _user?.email;

  String? get phoneNumber => _user?.phoneNumber;

  String? get role => _user?.role;

  String? get userImage => _user?.userImage;

  bool get emailVerified => _user?.emailVerified ?? false;

  bool get phoneVerified => _user?.phoneVerified ?? false;

  Future<void> saveUser(UserModel user) async {
    _user = user;

    final preferences = await SharedPreferences.getInstance();

    final userJson = jsonEncode({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'role': user.role,
      'userImage': user.userImage,
      'emailVerified': user.emailVerified,
      'phoneVerified': user.phoneVerified,
      'createdAt': user.createdAt.toIso8601String(),
    });

    await preferences.setString(_userKey, userJson);

    notifyListeners();
  }

  Future<bool> loadSavedUser() async {
    final preferences = await SharedPreferences.getInstance();

    final userString = preferences.getString(_userKey);

    if (userString == null || userString.isEmpty) {
      return false;
    }

    try {
      final data = jsonDecode(userString);

      _user = UserModel(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        role: data['role'] ?? 'customer',
        userImage: data['userImage'],
        emailVerified: data['emailVerified'] ?? false,
        phoneVerified: data['phoneVerified'] ?? false,
        createdAt: DateTime.parse(data['createdAt']),
      );

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Failed to restore saved user: $e');

      await clearUser();

      return false;
    }
  }

  Future<void> clearUser() async {
    _user = null;

    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_userKey);

    notifyListeners();
  }
}
