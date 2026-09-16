import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/data/models/product_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // CUSTOMER ORDERS
  // ============================================================

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return _orderFromFirestore(doc.id, doc.data());
    }).toList();
  }

  // ============================================================
  // ADMIN - ALL ORDERS
  // ============================================================

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _firestore
        .collectionGroup('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return _orderFromFirestore(doc.id, doc.data());
    }).toList();
  }

  // ============================================================
  // GET SINGLE ORDER
  // ============================================================

  Future<OrderModel?> getOrderById(String userId, String orderId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return _orderFromFirestore(doc.id, doc.data()!);
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================
  //
  // Creates:
  //
  // users
  //   └── USER_ID
  //       └── orders
  //           └── ORDER_ID
  //
  // Returns the generated Firestore ORDER_ID.
  //
  // ============================================================

  Future<String?> createOrder({
    required String userId,
    required OrderModel order,
  }) async {
    try {
      final orderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc();

      await orderRef.set({
        'userId': userId,

        'customerName': order.customerName,

        'customerEmail': order.customerEmail,

        'items': order.items.map((item) {
          return {'quantity': item.quantity, 'product': item.product.toMap()};
        }).toList(),

        'total': order.total,

        'paymentMethod': order.paymentMethod,

        'paymentStatus': order.paymentStatus,

        'orderStatus': order.orderStatus,

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),
      });

      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================
  //
  // Used by ADMIN.
  //
  // Examples:
  //
  // pending
  // processing
  // dispatched
  // delivered
  // cancelled
  //
  // ============================================================

  Future<void> updateOrderStatus({
    required String userId,
    required String orderId,
    required String orderStatus,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
            'orderStatus': orderStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ============================================================
  // UPDATE PAYMENT STATUS
  // ============================================================
  //
  // Used after successful M-Pesa payment.
  //
  // Updates BOTH:
  //
  // paymentStatus = paid
  // orderStatus   = processing
  //
  // ============================================================

  Future<void> updatePaymentStatus({
    required String userId,
    required String orderId,
    required String paymentStatus,
    required String orderStatus,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
            'paymentStatus': paymentStatus,

            'orderStatus': orderStatus,

            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // ============================================================
  // UPDATE ORDER PAYMENT + STATUS TOGETHER
  // ============================================================
  //
  // This is useful for the admin dashboard.
  //
  // Example:
  //
  // await repository.updateOrder(
  //   userId: userId,
  //   orderId: orderId,
  //   paymentStatus: 'paid',
  //   orderStatus: 'processing',
  // );
  //
  // ============================================================

  Future<void> updateOrder({
    required String userId,
    required String orderId,
    String? paymentStatus,
    String? orderStatus,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentStatus != null) {
        updates['paymentStatus'] = paymentStatus;
      }

      if (orderStatus != null) {
        updates['orderStatus'] = orderStatus;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // ============================================================
  // FIRESTORE → ORDER MODEL
  // ============================================================

  OrderModel _orderFromFirestore(String id, Map<String, dynamic> data) {
    // ----------------------------------------------------------
    // ITEMS
    // ----------------------------------------------------------

    final rawItems = data['items'] as List<dynamic>? ?? [];

    final List<OrderItem> items = rawItems.map((item) {
      final itemData = Map<String, dynamic>.from(item as Map);

      final rawProduct = itemData['product'];

      final Map<String, dynamic> productData = rawProduct is Map
          ? Map<String, dynamic>.from(rawProduct)
          : {};

      final productId = productData['id']?.toString() ?? '';

      final product = ProductModel.fromMap(productData, productId);

      final quantityValue = itemData['quantity'];

      final quantity = quantityValue is num
          ? quantityValue.toInt()
          : int.tryParse(quantityValue?.toString() ?? '') ?? 1;

      return OrderItem(product: product, quantity: quantity);
    }).toList();

    // ----------------------------------------------------------
    // CREATED AT
    // ----------------------------------------------------------

    final createdAtValue = data['createdAt'];

    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    // ----------------------------------------------------------
    // TOTAL
    // ----------------------------------------------------------

    final totalValue = data['total'];

    final double total = totalValue is num
        ? totalValue.toDouble()
        : double.tryParse(totalValue?.toString() ?? '') ?? 0.0;

    // ----------------------------------------------------------
    // ORDER MODEL
    // ----------------------------------------------------------

    return OrderModel(
      id: id,

      userId: data['userId']?.toString() ?? '',

      customerName: data['customerName']?.toString() ?? '',

      customerEmail: data['customerEmail']?.toString() ?? '',

      items: items,

      total: total,

      paymentMethod: data['paymentMethod']?.toString() ?? '',

      paymentStatus: data['paymentStatus']?.toString() ?? 'pending',

      orderStatus: data['orderStatus']?.toString() ?? 'pending',

      createdAt: createdAt,
    );
  }
}
