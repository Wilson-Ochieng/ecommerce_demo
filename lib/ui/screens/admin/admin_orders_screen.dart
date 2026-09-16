import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/ui/screens/viewmodels/admin_orders_viewmodel.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrdersViewModel>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management'), centerTitle: true),
      body: Consumer<AdminOrdersViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadOrders,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.orders.isEmpty) {
            return const Center(child: Text('No orders available.'));
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.orders.length,
              itemBuilder: (context, index) {
                final order = viewModel.orders[index];

                return _orderCard(context, viewModel, order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _orderCard(BuildContext context,
      AdminOrdersViewModel viewModel,
      OrderModel order,) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                _statusChip(order.orderStatus),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              order.customerName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            Text(order.customerEmail),

            const SizedBox(height: 12),

            Text('${order.itemCount} item(s)'),

            const SizedBox(height: 4),

            Text(
              'Total: KES ${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              'Payment: ${order.paymentMethod} • '
                  '${order.paymentStatus}',
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            ...order.items.map(
                  (item) =>
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(item.product.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Text('KES ${item.subtotal.toStringAsFixed(2)}'),
                  ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showStatusDialog(context, viewModel, order);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update Status'),
                  ),
                ),

                const SizedBox(width: 12),

                if (order.orderStatus != 'dispatched')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isDispatching
                          ? null
                          : () {
                        _dispatchOrder(
                          context,
                          viewModel,
                          order,
                        );
                      },
                      icon: viewModel.isDispatching
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.local_shipping_outlined,
                      ),
                      label: Text(
                        viewModel.isDispatching
                            ? 'Dispatching...'
                            : 'Dispatch',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    return Chip(label: Text(status.toUpperCase()));
  }

  // ============================================================
  // STATUS DIALOG
  // ============================================================

  Future<void> _showStatusDialog(BuildContext context,
      AdminOrdersViewModel viewModel,
      OrderModel order,) async {
    String selectedStatus = order.orderStatus;

    final status = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Order #${order.id}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'processing',
                    child: Text('Processing'),
                  ),
                  DropdownMenuItem(value: 'packed', child: Text('Packed')),
                  DropdownMenuItem(
                    value: 'dispatched',
                    child: Text('Dispatched'),
                  ),
                  DropdownMenuItem(
                    value: 'delivered',
                    child: Text('Delivered'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, selectedStatus);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (status == null) return;

    final success = await viewModel.updateOrderStatus(
      userId: order.userId,
      orderId: order.id,
      status: status,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Order status updated.'
              : viewModel.errorMessage ?? 'Failed to update order.',
        ),
      ),
    );
  }

  // ============================================================
  // DISPATCH ORDER
  // ============================================================


  Future<void> _dispatchOrder(BuildContext context,
      AdminOrdersViewModel viewModel,
      OrderModel order,) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Dispatch Order',
          ),

          content: Text(
            'Dispatch order #${order.id} '
                'to ${order.customerName}?\n\n'
                'A notification email will be sent '
                'to ${order.customerEmail}.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(
                Icons.local_shipping,
              ),
              label: const Text(
                'Dispatch',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

// ==========================================================
// SHOW PROGRESS
// ==========================================================

    final success =
    await viewModel.dispatchOrder(order);

    if (!context.mounted) {
      return;
    }

// ==========================================================
// RESULT
// ==========================================================

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,

        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle
                  : Icons.error_outline,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                success
                    ? 'Order dispatched and customer notified.'
                    : viewModel.errorMessage ??
                    'Failed to dispatch order.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}




