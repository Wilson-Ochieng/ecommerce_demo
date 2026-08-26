import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/data/services/firebase_auth_service.dart';


class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository({
    FirebaseAuthService? authService,
  }) : _authService = authService ?? FirebaseAuthService();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _authService.signIn(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password, required String name,
  }) async {
    return await _authService.register(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  User? get currentUser {
    return _authService.currentUser;
  }
}