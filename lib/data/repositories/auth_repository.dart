import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore =
            firestore ?? FirebaseFirestore.instance;

  // REGISTER
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception(
        'Unable to create Firebase account.',
      );
    }

    // Send verification email
    await firebaseUser.sendEmailVerification();

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      role: 'customer',
      emailVerified: false,
      createdAt: DateTime.now(),
    );

    // Create Firestore document using Firebase UID
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(user.toMap());

    return user;
  }

  // LOGIN
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception(
        'Unable to login.',
      );
    }

    // Refresh Firebase user
    await firebaseUser.reload();

    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'Authenticated user could not be found.',
      );
    }

    // Check verification
    if (!currentUser.emailVerified) {
      await _auth.signOut();

      throw Exception(
        'Please verify your email before logging in.',
      );
    }

    // Get Firestore profile
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists) {
      throw Exception(
        'User profile does not exist in Firestore.',
      );
    }

    return UserModel.fromMap(
      snapshot.data()!,
    );
  }

  // RESEND VERIFICATION
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    await user.sendEmailVerification();
  }

  // CHECK VERIFICATION
  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}