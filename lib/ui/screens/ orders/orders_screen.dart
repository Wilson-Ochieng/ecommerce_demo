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

    // Load orders after the screen has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId.isNotEmpty) {
        context.read<OrdersViewModel>().loadOrders(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // CHECK USER ID
    // =========================================================

    if (widget.userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Unable to load orders.\n'
              'No logged-in user was found.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // =======================================================
      // ORDERS BODY
      // =======================================================
      body: Consumer<OrdersViewModel>(
        builder: (context, viewModel, child) {
          // =====================================================
          // LOADING
          // =====================================================

          if (viewModel.isLoading && viewModel.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // =====================================================
          // ERROR
          // =====================================================

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

                    ElevatedButton.icon(
                      onPressed: () {
                        viewModel.loadOrders(widget.userId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // =====================================================
          // EMPTY
          // =====================================================

          if (viewModel.orders.isEmpty) {
            return const EmptyOrdersWidget();
          }

          // =====================================================
          // ORDERS
          // =====================================================

          return RefreshIndicator(
            onRefresh: () {
              return viewModel.refreshOrders(widget.userId);
            },

            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),

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
