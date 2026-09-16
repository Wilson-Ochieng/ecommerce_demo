import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? userImage;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.userImage,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
  });

  // ============================================================
  // FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'userImage': userImage,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ============================================================
  // LOCAL STORAGE / JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'userImage': userImage,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'customer',
      userImage: map['userImage'] as String?,
      emailVerified: map['emailVerified'] ?? false,
      phoneVerified: map['phoneVerified'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // ============================================================
  // FROM LOCAL JSON
  // ============================================================

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'customer',
      userImage: json['userImage'] as String?,
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
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
    String? userImage,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      userImage: userImage ?? this.userImage,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
