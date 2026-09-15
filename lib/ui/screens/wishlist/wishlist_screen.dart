import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/wishlist_viewmodel.dart';
import '../widgets/empty_wishlist_widget.dart';
import '../widgets/wishlist_card.dart';

class WishlistScreen extends StatefulWidget {
  final String userId;

  const WishlistScreen({super.key, required this.userId});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistViewModel>().loadWishlist(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist'), centerTitle: true),
      body: Consumer<WishlistViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(context, viewModel);
          }

          if (viewModel.isEmpty) {
            return EmptyWishlistWidget(
              onStartShopping: () {
                Navigator.pop(context);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return viewModel.refreshWishlist(widget.userId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.wishlist.length,
              itemBuilder: (context, index) {
                final product = viewModel.wishlist[index];

                return WishlistCard(
                  product: product,
                  onRemove: () {
                    _removeWishlistItem(
                      context,
                      viewModel,
                      product.id,
                      product.name,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WishlistViewModel viewModel) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),

            const SizedBox(height: 16),

            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                viewModel.loadWishlist(widget.userId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeWishlistItem(
    BuildContext context,
    WishlistViewModel viewModel,
    String productId,
    String productName,
  ) async {
    await viewModel.removeFromWishlist(
      userId: widget.userId,
      productId: productId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName removed from wishlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Undo can be implemented once the repository
            // supports restoring the removed product.
          },
        ),
      ),
    );
  }
}
