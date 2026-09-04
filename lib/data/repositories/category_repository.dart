import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  // ==========================================================
  // GET CATEGORIES
  // ==========================================================

  Stream<List<CategoryModel>> getCategories() {
    return _categories.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // ==========================================================
  // ADD CATEGORY
  // ==========================================================

  Future<void> addCategory(String name) async {
    final categoryName = name.trim();

    if (categoryName.isEmpty) {
      throw Exception('Category name cannot be empty.');
    }

    final existing = await _categories
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Category already exists.');
    }

    await _categories.add({
      'name': categoryName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // UPDATE CATEGORY
  // ==========================================================

  Future<void> updateCategory(String categoryId, String name) async {
    final categoryName = name.trim();

    if (categoryName.isEmpty) {
      throw Exception('Category name cannot be empty.');
    }

    final existing = await _categories
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    final duplicate = existing.docs.any((doc) => doc.id != categoryId);

    if (duplicate) {
      throw Exception('Another category with this name already exists.');
    }

    await _categories.doc(categoryId).update({'name': categoryName});
  }

  // ==========================================================
  // DELETE CATEGORY
  // ==========================================================

  Future<void> deleteCategory(String categoryId) async {
    await _categories.doc(categoryId).delete();
  }
}
