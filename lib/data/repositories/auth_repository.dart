import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? _verificationId;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Unable to create Firebase account.');
    }

    // ==========================================================
    // SEND EMAIL VERIFICATION
    // ==========================================================

    try {
      await firebaseUser.sendEmailVerification();

      print('Verification email requested for: ${firebaseUser.email}');
    } on FirebaseAuthException catch (e) {
      print('EMAIL VERIFICATION ERROR');
      print('Code: ${e.code}');
      print('Message: ${e.message}');

      throw Exception(e.message ?? 'Failed to send verification email.');
    }

    // ==========================================================
    // CREATE FIRESTORE USER PROFILE
    // ==========================================================
    final user = UserModel(
      uid: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      role: 'customer',
      emailVerified: false,
      phoneVerified: false,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        ...user.toMap(),

        // Store phone number separately
        'phoneNumber': phoneNumber.trim(),

        // Phone verification status
        'phoneVerified': false,
      });
    } catch (e) {
      // If Firestore creation fails,
      // remove the Firebase Authentication account.

      await firebaseUser.delete();

      rethrow;
    }

    return user;
  }

  // ============================================================
  // SEND PHONE OTP
  // ============================================================

  Future<void> sendPhoneVerificationCode({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),

      // --------------------------------------------------------
      // ANDROID ONLY
      // --------------------------------------------------------
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth.currentUser?.linkWithCredential(credential);
        } catch (e) {
          // Automatic verification may fail if the
          // phone number is already linked.
        }
      },

      // --------------------------------------------------------
      // VERIFICATION FAILED
      // --------------------------------------------------------
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message ?? 'Phone verification failed.');
      },

      // --------------------------------------------------------
      // OTP SENT
      // --------------------------------------------------------
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },

      // --------------------------------------------------------
      // AUTO RETRIEVAL TIMEOUT
      // --------------------------------------------------------
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // ============================================================
  // VERIFY PHONE OTP
  // ============================================================

  Future<void> verifyPhoneCode({required String smsCode}) async {
    if (_verificationId == null) {
      throw Exception(
        'Verification session has expired. Please request a new code.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode.trim(),
    );

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      // Link phone credential to existing
      // email/password account.
      await user.linkWithCredential(credential);

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'phoneVerified': true,
        'phoneNumber': user.phoneNumber,
      });

      // Clear verification ID
      _verificationId = null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception(
          'This phone number is already associated with another account.',
        );
      }

      if (e.code == 'invalid-verification-code') {
        throw Exception('The verification code is incorrect.');
      }

      if (e.code == 'session-expired') {
        throw Exception(
          'The verification code has expired. Request a new code.',
        );
      }

      throw Exception(e.message ?? 'Phone verification failed.');
    }
  }

  // ============================================================
  // RESEND PHONE OTP
  // ============================================================

  Future<void> resendPhoneVerificationCode({
    required String phoneNumber,
  }) async {
    _verificationId = null;

    await sendPhoneVerificationCode(phoneNumber: phoneNumber);
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Unable to login.');
    }

    // Refresh Firebase user
    await firebaseUser.reload();

    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('Authenticated user could not be found.');
    }

    // ==========================================================
    // EMAIL VERIFICATION
    // ==========================================================

    if (!currentUser.emailVerified) {
      await _auth.signOut();

      throw Exception('Please verify your email before logging in.');
    }

    // ==========================================================
    // FIRESTORE PROFILE
    // ==========================================================

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists) {
      throw Exception('User profile does not exist in Firestore.');
    }

    return UserModel.fromMap(snapshot.data()!);
  }

  // ============================================================
  // CHECK EMAIL VERIFICATION
  // ============================================================

  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  // ============================================================
  // RESEND EMAIL VERIFICATION
  // ============================================================

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await user.sendEmailVerification();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // GET CURRENT USER PROFILE
  // ============================================================

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    // No Firebase user is currently signed in
    if (firebaseUser == null) {
      return null;
    }

    // Refresh Firebase authentication state
    await firebaseUser.reload();

    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return null;
    }

    // User must have verified their email
    if (!currentUser.emailVerified) {
      await _auth.signOut();
      return null;
    }

    // Get the user's Firestore profile
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      await _auth.signOut();

      throw Exception('User profile does not exist in Firestore.');
    }

    return UserModel.fromMap(snapshot.data()!);
  }

  // ============================================================
  // GET ALL USERS
  // ============================================================

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserModel.fromMap(doc.data());
          }).toList();
        });
  }

  // ============================================================
  // UPDATE USER ROLE
  // ============================================================

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    // Only allow application roles that
    // our application understands.

    if (role != 'admin' && role != 'customer') {
      throw Exception('Invalid user role.');
    }

    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  // ============================================================
  // DELETE USER FIRESTORE PROFILE
  // ============================================================
  // ============================================================

  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
