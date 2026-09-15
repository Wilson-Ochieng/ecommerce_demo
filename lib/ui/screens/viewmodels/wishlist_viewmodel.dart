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

  List<ProductModel> get wishlist => List.unmodifiable(_wishlist);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => _wishlist.isEmpty;

  bool contains(String productId) {
    return _wishlist.any((product) => product.id == productId);
  }

  Future<void> loadWishlist(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wishlist = await _repository.getWishlist(userId);
    } catch (e) {
      _errorMessage = 'Failed to load your wishlist.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist({
    required String userId,
    required ProductModel product,
  }) async {
    if (contains(product.id)) {
      return;
    }

    try {
      await _repository.addToWishlist(userId: userId, product: product);

      _wishlist = [..._wishlist, product];

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add product to wishlist.';
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
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

  Future<void> refreshWishlist(String userId) async {
    await loadWishlist(userId);
  }
}
