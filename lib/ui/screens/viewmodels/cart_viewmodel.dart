import 'package:flutter/foundation.dart';
import 'package:test_app/data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartViewModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => Map.unmodifiable(_items);

  List<CartItem> get cartItems => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get total => subtotal;

  // ============================================================
  // ADD TO CART
  // ============================================================

  void addToCart(ProductModel product) {
    final existingItem = _items[product.id];

    if (existingItem != null) {
      // Prevent quantity from exceeding stock
      if (existingItem.quantity >= product.stock) {
        return;
      }

      existingItem.quantity++;
    } else {
      // Do not add out-of-stock products
      if (product.stock <= 0) {
        return;
      }

      _items[product.id] = CartItem(product: product, quantity: 1);
    }

    notifyListeners();
  }

  // ============================================================
  // INCREMENT
  // ============================================================

  void increment(String productId) {
    final item = _items[productId];

    if (item == null) return;

    if (item.quantity >= item.product.stock) {
      return;
    }

    item.quantity++;

    notifyListeners();
  }

  // ============================================================
  // DECREMENT
  // ============================================================

  void decrement(String productId) {
    final item = _items[productId];

    if (item == null) return;

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }

  // ============================================================
  // REMOVE
  // ============================================================

  void removeItem(String productId) {
    _items.remove(productId);

    notifyListeners();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearCart() {
    _items.clear();

    notifyListeners();
  }

  // ============================================================
  // CHECK PRODUCT
  // ============================================================

  bool contains(String productId) {
    return _items.containsKey(productId);
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  int quantityOf(String productId) {
    return _items[productId]?.quantity ?? 0;
  }
}
