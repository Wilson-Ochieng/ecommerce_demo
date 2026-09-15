import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/orders_viewmodel.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  final String userId;

  const OrdersScreen({super.key, required this.userId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersViewModel>().loadOrders(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Consumer<OrdersViewModel>(
        builder: (context, viewModel, child) {
          // =========================================================
          // LOADING
          // =========================================================

          if (viewModel.isLoading && viewModel.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // =========================================================
          // ERROR
          // =========================================================

          if (viewModel.errorMessage != null && viewModel.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red.shade400,
                    ),

                    const SizedBox(height: 15),

                    Text(viewModel.errorMessage!, textAlign: TextAlign.center),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        viewModel.loadOrders(widget.userId);
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // =========================================================
          // EMPTY
          // =========================================================

          if (viewModel.isEmpty) {
            return const EmptyOrdersWidget();
          }

          // =========================================================
          // ORDERS
          // =========================================================

          return RefreshIndicator(
            onRefresh: () {
              return viewModel.refreshOrders(widget.userId);
            },

            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

              itemCount: viewModel.orders.length,

              itemBuilder: (context, index) {
                final order = viewModel.orders[index];

                return OrderCard(
                  order: order,

                  onTap: () {
                    // TODO:
                    // Navigate to OrderDetailsScreen
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
