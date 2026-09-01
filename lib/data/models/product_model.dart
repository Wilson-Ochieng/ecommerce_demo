import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.createdAt,
  });

  // Convert model -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,

      // DateTime -> Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert Firestore -> model
  factory ProductModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      stock: (map['stock'] ?? 0).toInt(),

      // Timestamp -> DateTime
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}