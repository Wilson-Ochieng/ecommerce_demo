import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/ui/screens/viewmodels/checkout_viewmodel.dart';

import '../../../ui/screens/viewmodels/cart_viewmodel.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutViewModel(),
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
                : () {
                    checkout.checkout(
                      cart: cart,
                      phoneNumber: _phoneController.text.trim(),
                    );
                  },
            child: checkout.isLoading
                ? const CircularProgressIndicator()
                : Text(isMpesa ? 'Pay with M-Pesa' : 'Place Order'),
          ),
        ),
      ),
    );
  }
}
