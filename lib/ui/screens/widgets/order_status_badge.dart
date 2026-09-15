import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();

    Color color;
    IconData icon;

    switch (normalizedStatus) {
      case 'paid':
      case 'delivered':
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;

      case 'pending':
      case 'processing':
        color = Colors.orange;
        icon = Icons.access_time;
        break;

      case 'failed':
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;

      case 'shipped':
        color = Colors.blue;
        icon = Icons.local_shipping_outlined;
        break;

      default:
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),

          const SizedBox(width: 4),

          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
