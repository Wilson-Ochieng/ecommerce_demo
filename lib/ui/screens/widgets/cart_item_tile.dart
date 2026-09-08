import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';
import 'package:test_app/ui/screens/widgets/quantity_button.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartViewModel>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 75,
              height: 75,
              child: item.product.imageUrl.isNotEmpty
                  ? Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          // PRODUCT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'KES ${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // QUANTITY
                Row(
                  children: [
                    QuantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        cart.decrement(item.product.id);
                      },
                    ),

                    Container(
                      width: 35,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    QuantityButton(
                      icon: Icons.add,
                      onPressed: item.quantity < item.product.stock
                          ? () {
                              cart.increment(item.product.id);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // DELETE + SUBTOTAL
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  cart.removeItem(item.product.id);
                },
              ),

              Text(
                'KES ${item.subtotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
