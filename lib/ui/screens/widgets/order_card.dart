import 'package:flutter/material.dart';

import 'package:test_app/data/models/order_model.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // ORDER HEADER
              // =====================================================

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  OrderStatusBadge(status: order.orderStatus),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                _formatDate(order.createdAt),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const Divider(height: 24),

              // =====================================================
              // ORDER INFO
              // =====================================================
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                  ),

                  const Spacer(),

                  Text(
                    'KES ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =====================================================
              // PAYMENT
              // =====================================================
              Row(
                children: [
                  Icon(
                    order.paymentMethod.toLowerCase() == 'mpesa'
                        ? Icons.phone_android
                        : Icons.money_outlined,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    order.paymentMethod,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const Spacer(),

                  _paymentStatus(order.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentStatus(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;

      case 'failed':
        color = Colors.red;
        break;

      default:
        color = Colors.orange;
    }

    return Text(
      status.toUpperCase(),
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
