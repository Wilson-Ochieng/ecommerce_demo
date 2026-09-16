import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:test_app/data/models/product_model.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // WISHLIST COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> _wishlistCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('wishlist');
  }

  // ============================================================
  // GET WISHLIST
  // ============================================================

  Future<List<ProductModel>> getWishlist(String userId) async {
    final snapshot = await _wishlistCollection(userId).get();

    return snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // ============================================================
  // ADD TO WISHLIST
  // ============================================================

  Future<void> addToWishlist({
    required String userId,
    required ProductModel product,
  }) async {
    await _wishlistCollection(userId).doc(product.id).set({
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'category': product.category,
      'stock': product.stock,
      'createdAt': Timestamp.fromDate(product.createdAt),
    });
  }

  // ============================================================
  // REMOVE FROM WISHLIST
  // ============================================================

  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    await _wishlistCollection(userId).doc(productId).delete();
  }

  // ============================================================
  // CHECK WISHLIST
  // ============================================================

  Future<bool> isInWishlist({
    required String userId,
    required String productId,
  }) async {
    final document = await _wishlistCollection(userId).doc(productId).get();

    return document.exists;
  }
}
