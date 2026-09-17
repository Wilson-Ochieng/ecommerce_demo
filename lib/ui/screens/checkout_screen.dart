import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/order_model.dart';
import 'package:test_app/providers/UserProvider.dart';
import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/checkout_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/orders_viewmodel.dart';

import ' orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();

  Future<void> _processCheckout(
    BuildContext context,
    CheckoutViewModel checkout,
    CartViewModel cart,
  ) async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    // ----------------------------------------------------------
    // USER VALIDATION
    // ----------------------------------------------------------
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before placing an order.')),
      );
      return;
    }

    // ----------------------------------------------------------
    // CART VALIDATION
    // ----------------------------------------------------------
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    final isMpesa = checkout.paymentMethod == PaymentMethod.mpesa;

    final ordersViewModel = context.read<OrdersViewModel>();

    // ----------------------------------------------------------
    // 1. CREATE ORDER FIRST
    // ----------------------------------------------------------
    final order = OrderModel(
      id: '',
      userId: user.uid,
      customerName: user.name,
      customerEmail: user.email,
      items: cart.cartItems
          .map(
            (item) => OrderItem(product: item.product, quantity: item.quantity),
          )
          .toList(),
      total: cart.total,
      paymentMethod: isMpesa ? 'M-Pesa' : 'Cash',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      createdAt: DateTime.now(),
    );

    final orderId = await ordersViewModel.createOrder(
      userId: user.uid,
      order: order,
    );

    if (!context.mounted) return;

    // ----------------------------------------------------------
    // ORDER CREATION FAILED
    // ----------------------------------------------------------
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ordersViewModel.errorMessage ?? 'Unable to create order.',
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // 2. CASH PAYMENT
    // ----------------------------------------------------------
    if (!isMpesa) {
      cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order placed successfully. Payment will be made in cash.',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrdersScreen(userId: user.uid)),
        (route) => route.isFirst,
      );

      return;
    }

    // ----------------------------------------------------------
    // 3. M-PESA PAYMENT
    // ----------------------------------------------------------
    final success = await checkout.checkout(
      cart: cart,
      phoneNumber: _phoneController.text.trim(),
      orderId: orderId.toString(),
      customerName: user.name,
      customerEmail: user.email,
    );

    if (!context.mounted) return;

    // ----------------------------------------------------------
    // M-PESA PAYMENT FAILED
    // ----------------------------------------------------------
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            checkout.message.isNotEmpty
                ? checkout.message
                : 'M-Pesa payment failed.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // 4. UPDATE ORDER AFTER SUCCESSFUL M-PESA PAYMENT
    // ----------------------------------------------------------
    final paymentUpdated = await ordersViewModel.updatePaymentStatus(
      userId: user.uid,
      orderId: orderId,
      paymentStatus: 'paid',
      orderStatus: 'processing',
    );

    if (!context.mounted) return;

    // ----------------------------------------------------------
    // ORDER UPDATE FAILED
    // ----------------------------------------------------------
    if (!paymentUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment was successful, but the order status could not be updated.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // 5. CLEAR CART
    // ----------------------------------------------------------
    cart.clearCart();

    // ----------------------------------------------------------
    // 6. SHOW SUCCESS MESSAGE
    // ----------------------------------------------------------
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('M-Pesa payment successful. Order placed.')),
    );

    // ----------------------------------------------------------
    // 7. GO TO ORDERS
    // ----------------------------------------------------------
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrdersScreen(userId: user.uid)),
      (route) => route.isFirst,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CheckoutViewModel(
            userProvider: context.read<UserProvider>(),
          ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Consumer2<CheckoutViewModel, CartViewModel>(
          builder: (context, checkout, cart, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummary(cart),

                        const SizedBox(height: 24),

                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _paymentMethod(
                          context,
                          checkout,
                          PaymentMethod.mpesa,
                          'M-Pesa',
                          'Pay using M-Pesa STK Push',
                          Icons.phone_android,
                        ),

                        _paymentMethod(
                          context,
                          checkout,
                          PaymentMethod.cash,
                          'Cash',
                          'Pay with cash',
                          Icons.money,
                        ),

                        if (checkout.paymentMethod == PaymentMethod.mpesa) ...[
                          const SizedBox(height: 16),

                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'M-Pesa Phone Number',
                              hintText: '2547XXXXXXXX',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        if (checkout.message.isNotEmpty)
                          _buildPaymentMessage(checkout),
                      ],
                    ),
                  ),
                ),

                _buildPayButton(context, checkout, cart),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartViewModel cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text('${cart.itemCount} item(s)'),

            const SizedBox(height: 8),

            Text(
              'Total: KES ${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethod(
    BuildContext context,
    CheckoutViewModel checkout,
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: checkout.paymentMethod,
        onChanged: checkout.isLoading
            ? null
            : (value) {
                if (value != null) {
                  checkout.selectPaymentMethod(value);
                }
              },
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
      ),
    );
  }

  Widget _buildPaymentMessage(CheckoutViewModel checkout) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (checkout.isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.info_outline),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                checkout.message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(
    BuildContext context,
    CheckoutViewModel checkout,
    CartViewModel cart,
  ) {
    final isMpesa = checkout.paymentMethod == PaymentMethod.mpesa;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: checkout.isLoading
                ? null
                : () => _processCheckout(context, checkout, cart),
            child: checkout.isLoading
                ? const CircularProgressIndicator()
                : Text(isMpesa ? 'Pay with M-Pesa' : 'Place Order'),
          ),
        ),
      ),
    );
  }
}
