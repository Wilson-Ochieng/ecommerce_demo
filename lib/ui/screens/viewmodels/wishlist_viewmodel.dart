import 'package:flutter/foundation.dart';

import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/data/repositories/wishlist_repository.dart';

class WishlistViewModel extends ChangeNotifier {
  final WishlistRepository _repository;

  WishlistViewModel({WishlistRepository? repository})
    : _repository = repository ?? WishlistRepository();

  List<ProductModel> _wishlist = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<ProductModel> get wishlist => List.unmodifiable(_wishlist);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => _wishlist.isEmpty;

  bool contains(String productId) {
    return _wishlist.any((product) => product.id == productId);
  }

  // ============================================================
  // LOAD WISHLIST
  // ============================================================

  Future<void> loadWishlist(String userId) async {
    if (userId.trim().isEmpty) {
      _errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final wishlist = await _repository.getWishlist(userId);

      _wishlist = wishlist;
    } catch (e) {
      _errorMessage = 'Failed to load your wishlist.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ADD TO WISHLIST
  // ============================================================

  Future<void> addToWishlist({
    required String userId,
    required ProductModel product,
  }) async {
    if (userId.trim().isEmpty) {
      _errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    // Prevent duplicates
    if (contains(product.id)) {
      return;
    }

    try {
      _errorMessage = null;

      await _repository.addToWishlist(userId: userId, product: product);

      _wishlist = [..._wishlist, product];

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add product to wishlist.';

      notifyListeners();
    }
  }

  // ============================================================
  // REMOVE FROM WISHLIST
  // ============================================================

  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    if (userId.trim().isEmpty) {
      _errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    try {
      _errorMessage = null;

      await _repository.removeFromWishlist(
        userId: userId,
        productId: productId,
      );

      _wishlist.removeWhere((product) => product.id == productId);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove product from wishlist.';

      notifyListeners();
    }
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

  Future<void> toggleWishlist({
    required String userId,
    required ProductModel product,
  }) async {
    if (contains(product.id)) {
      await removeFromWishlist(userId: userId, productId: product.id);
    } else {
      await addToWishlist(userId: userId, product: product);
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshWishlist(String userId) async {
    await loadWishlist(userId);
  }

  // ============================================================
  // CLEAR LOCAL WISHLIST
  // ============================================================

  void clearWishlist() {
    _wishlist = [];
    _errorMessage = null;

    notifyListeners();
  }
}
