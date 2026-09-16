import 'package:test_app/data/models/product_model.dart';

class OrderItem {
  final ProductModel product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;

  final List<OrderItem> items;
  final double total;

  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;

  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
  });

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isPaid {
    return paymentStatus.toLowerCase() == 'paid';
  }

  bool get isPending {
    return paymentStatus.toLowerCase() == 'pending';
  }

  bool get isFailed {
    return paymentStatus.toLowerCase() == 'failed';
  }
}
