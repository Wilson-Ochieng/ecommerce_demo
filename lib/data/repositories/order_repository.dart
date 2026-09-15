import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/data/models/product_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // =========================================================
  // GET USER ORDERS
  // =========================================================

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return _orderFromFirestore(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  // =========================================================
  // GET SINGLE ORDER
  // =========================================================

  Future<OrderModel?> getOrderById(
      String userId,
      String orderId,
      ) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return _orderFromFirestore(
      doc.id,
      doc.data()!,
    );
  }

  // =========================================================
  // FIRESTORE -> ORDER MODEL
  // =========================================================

  OrderModel _orderFromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    final rawItems = data['items'] as List<dynamic>? ?? [];

    final items = rawItems.map((item) {
      final itemData = Map<String, dynamic>.from(item);

      final productData = Map<String, dynamic>.from(
        itemData['product'] ?? {},
      );

      final productId = productData['id'] ?? '';

      final product = ProductModel.fromMap(
        productData,
        productId,
      );

      return OrderItem(
        product: product,
        quantity: (itemData['quantity'] ?? 1).toInt(),
      );
    }).toList();

    final createdAt = data['createdAt'];

    return OrderModel(
      id: id,
      items: items,
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      orderStatus: data['orderStatus'] ?? 'pending',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now(),
    );
  }
}