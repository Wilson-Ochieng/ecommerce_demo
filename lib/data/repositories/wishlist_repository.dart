import 'package:test_app/data/models/product_model.dart';

class WishlistRepository {
  Future<List<ProductModel>> getWishlist(String userId) async {
    // TODO: Replace with Firestore implementation.
    await Future.delayed(const Duration(milliseconds: 500));

    return [];
  }

  Future<void> addToWishlist({
    required String userId,
    required ProductModel product,
  }) async {
    // TODO: Save wishlist item to Firestore.
  }

  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    // TODO: Remove wishlist item from Firestore.
  }
}
