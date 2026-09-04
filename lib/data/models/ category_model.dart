import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'createdAt': Timestamp.fromDate(createdAt)};
  }

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];

    DateTime parsedCreatedAt;

    if (createdAt is Timestamp) {
      parsedCreatedAt = createdAt.toDate();
    } else if (createdAt is DateTime) {
      parsedCreatedAt = createdAt;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return CategoryModel(
      id: id,
      name: (map['name'] ?? '').toString(),
      createdAt: parsedCreatedAt,
    );
  }
}
