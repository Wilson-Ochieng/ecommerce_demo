import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;

  final bool emailVerified;
  final bool phoneVerified;

  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
  });

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'customer',

      emailVerified:
          map['emailVerified'] ?? false,

      phoneVerified:
          map['phoneVerified'] ?? false,

      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp)
              .toDate()
          : DateTime.now(),
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber:
          phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      emailVerified:
          emailVerified ?? this.emailVerified,
      phoneVerified:
          phoneVerified ?? this.phoneVerified,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}