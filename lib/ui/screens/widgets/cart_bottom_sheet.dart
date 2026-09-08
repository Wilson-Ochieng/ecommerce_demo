import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';
import 'package:test_app/ui/screens/widgets/empty_cart_widget.dart';
import 'package:test_app/ui/screens/widgets/cart_item_tile.dart';
import 'package:test_app/ui/screens/widgets/checkout_section.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cart, child) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // HANDLE
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 15),

                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Cart',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (cart.itemCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cart.itemCount} items',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // CART CONTENT
                Expanded(
                  child: cart.isEmpty
                      ? const EmptyCartWidget()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: cart.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cart.cartItems[index];

                            return CartItemTile(item: item);
                          },
                        ),
                ),

                // CHECKOUT
                if (!cart.isEmpty) CheckoutSection(cart: cart),
              ],
            ),
          ),
        );
      },
    );
  }
}
