import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String userImage;
  final Timestamp createdAt;
  final List userCart;
  final List userWish;
  final String role;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.userImage,
    required this.createdAt,
    required this.userCart,
    required this.userWish,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'userImage': userImage,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userCart': userCart,
      'userWish': userWish,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      userImage: map['userImage'] ?? '',
      createdAt: Timestamp.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? 0,
      ),
      userCart: List.from(map['userCart'] ?? []),
      userWish: List.from(map['userWish'] ?? []),
      role: map['role'] ?? 'user',
    );
  }
}