import 'package:flutter/material.dart';

class WishlistViewModel extends ChangeNotifier {
  final Set<String> _wishlistIds = {};

  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);

  bool isWishlisted(String productId) {
    return _wishlistIds.contains(productId);
  }

  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }

    notifyListeners();
  }

  void addToWishlist(String productId) {
    _wishlistIds.add(productId);
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _wishlistIds.remove(productId);
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistIds.clear();
    notifyListeners();
  }
}
