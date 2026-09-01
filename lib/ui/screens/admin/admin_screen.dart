import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/ui/screens/admin/product_form_screen.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';



class AdminScreen extends StatelessWidget {
  static const routeName = '/admin';

  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: viewModel.products,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products available.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: products.length,

            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Row(
                    children: [
                      // PRODUCT IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),

                        child: Image.network(
                          product.imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      // PRODUCT DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),

                            const SizedBox(height: 5),

                            Text(
                              product.category,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'KES ${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Stock: ${product.stock}',
                            ),
                          ],
                        ),
                      ),

                      // ACTIONS
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductFormScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _confirmDelete(
                                context,
                                product,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),

          content: Text(
            'Are you sure you want to delete ${product.name}?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final viewModel =
        context.read<ProductViewModel>();

    final success =
        await viewModel.deleteProduct(product.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Product deleted successfully'
              : 'Failed to delete product',
        ),
      ),
    );
  }
}