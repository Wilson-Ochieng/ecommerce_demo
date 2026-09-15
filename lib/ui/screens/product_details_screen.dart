import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartViewModel>();

    final quantity = cart.quantityOf(product.id);
    final isInCart = cart.contains(product.id);
    final isOutOfStock = product.stock <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // Navigate to cart if you have a CartScreen route.
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),

              if (cart.itemCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // PRODUCT IMAGE
                  // =====================================================
                  SizedBox(
                    width: double.infinity,
                    height: 320,
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _imagePlaceholder(context);
                            },
                          )
                        : _imagePlaceholder(context),
                  ),

                  // =====================================================
                  // PRODUCT DETAILS
                  // =====================================================
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CATEGORY
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // NAME
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // PRICE
                        Text(
                          'KES ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // STOCK
                        Row(
                          children: [
                            Icon(
                              isOutOfStock
                                  ? Icons.cancel_outlined
                                  : Icons.inventory_2_outlined,
                              size: 20,
                              color: isOutOfStock
                                  ? Colors.red
                                  : theme.colorScheme.primary,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              isOutOfStock
                                  ? 'Out of stock'
                                  : '${product.stock} items available',
                              style: TextStyle(
                                color: isOutOfStock
                                    ? Colors.red
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'No description available.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // QUANTITY
                        // =================================================
                        if (isInCart) ...[
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _QuantityButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  cart.decrement(product.id);
                                },
                              ),

                              Container(
                                width: 50,
                                alignment: Alignment.center,
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              _QuantityButton(
                                icon: Icons.add,
                                onPressed: quantity < product.stock
                                    ? () {
                                        cart.increment(product.id);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =============================================================
          // BOTTOM ACTION
          // =============================================================
          _BottomAction(product: product, cart: cart),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
      ),
    );
  }
}

// =====================================================================
// QUANTITY BUTTON
// =====================================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 38,
      height: 38,
      child: Material(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Icon(
            icon,
            color: onPressed == null ? Colors.grey : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// BOTTOM ACTION
// =====================================================================

class _BottomAction extends StatelessWidget {
  final ProductModel product;
  final CartViewModel cart;

  const _BottomAction({required this.product, required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final quantity = cart.quantityOf(product.id);
    final isOutOfStock = product.stock <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isOutOfStock
                ? null
                : () {
                    cart.addToCart(product);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            quantity > 0
                                ? '${product.name} quantity updated'
                                : '${product.name} added to cart',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(
              isOutOfStock
                  ? 'Out of Stock'
                  : quantity > 0
                  ? 'Add Another'
                  : 'Add to Cart',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
