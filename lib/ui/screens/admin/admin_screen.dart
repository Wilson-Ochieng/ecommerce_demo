import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/providers/ThemeProvider.dart';
import 'package:test_app/ui/screens/admin/category_management_screen.dart';
import 'package:test_app/ui/screens/admin/product_form_screen.dart';
import 'package:test_app/ui/screens/admin/user_management_screen.dart';
import 'package:test_app/ui/screens/auth/login_screen.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';

class AdminScreen extends StatelessWidget {
  static const routeName = '/admin';

  const AdminScreen({super.key});

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out of the admin account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final authViewModel = context.read<AuthStartupViewModel>();

    final success = await authViewModel.logout();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Failed to sign out.'),
        ),
      );
    }
  }

  // ============================================================
  // DELETE PRODUCT CONFIRMATION
  // ============================================================

  Future<void> _confirmDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final productViewModel = context.read<ProductViewModel>();

    final success = await productViewModel.deleteProduct(product.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Product deleted successfully.'
              : productViewModel.errorMessage ?? 'Failed to delete product.',
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATE TO PRODUCT FORM
  // ============================================================

  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
  }

  void _editProduct(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
  }

  // ============================================================
  // NAVIGATE TO CATEGORY MANAGEMENT
  // ============================================================

  void _openCategoryManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
    );
  }

  // ============================================================
  // NAVIGATE TO USER MANAGEMENT
  // ============================================================

  void _openUserManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserManagementScreen()),
    );
  }

  // ============================================================
  // MANAGEMENT CARD
  // ============================================================

  Widget _managementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _productCard(BuildContext context, ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // PRODUCT IMAGE
            // ----------------------------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    width: 90,
                    height: 90,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            // ----------------------------------------------------
            // PRODUCT DETAILS
            // ----------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'KES ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Stock: ${product.stock}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // ACTIONS
            // ----------------------------------------------------
            Column(
              children: [
                IconButton(
                  tooltip: 'Edit Product',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    _editProduct(context, product);
                  },
                ),

                IconButton(
                  tooltip: 'Delete Product',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, product);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final productViewModel = context.watch<ProductViewModel>();

    final isDarkMode = themeProvider.getIsDarkTHeme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),

        // --------------------------------------------------------
        // THEME + LOGOUT
        // --------------------------------------------------------
        actions: [
          IconButton(
            tooltip: isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              themeProvider.getIsDarkTHeme;
            },
          ),

          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              _confirmLogout(context);
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // ADD PRODUCT
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addProduct(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Manage products, categories and users.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // MANAGEMENT OPTIONS
                  // ------------------------------------------------
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: _managementCard(
                            context: context,
                            icon: Icons.category_outlined,
                            title: 'Categories',
                            description:
                                'Create, edit and delete product categories.',
                            onTap: () {
                              _openCategoryManagement(context);
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _managementCard(
                            context: context,
                            icon: Icons.people_outline,
                            title: 'Users',
                            description:
                                'Manage users and change account roles.',
                            onTap: () {
                              _openUserManagement(context);
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _managementCard(
                          context: context,
                          icon: Icons.category_outlined,
                          title: 'Categories',
                          description:
                              'Create, edit and delete product categories.',
                          onTap: () {
                            _openCategoryManagement(context);
                          },
                        ),

                        const SizedBox(height: 16),

                        _managementCard(
                          context: context,
                          icon: Icons.people_outline,
                          title: 'Users',
                          description: 'Manage users and change account roles.',
                          onTap: () {
                            _openUserManagement(context);
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // ------------------------------------------------
                  // PRODUCTS HEADER
                  // ------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Products',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
                          _addProduct(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // PRODUCT STREAM
                  // ------------------------------------------------
                  StreamBuilder<List<ProductModel>>(
                    stream: productViewModel.products,
                    builder: (context, snapshot) {
                      // --------------------------------------------
                      // LOADING
                      // --------------------------------------------

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // --------------------------------------------
                      // ERROR
                      // --------------------------------------------

                      if (snapshot.hasError) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 50),

                                const SizedBox(height: 12),

                                Text(
                                  'Unable to load products.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  snapshot.error.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final products = snapshot.data ?? [];

                      // --------------------------------------------
                      // EMPTY
                      // --------------------------------------------

                      if (products.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 60,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    'No products available.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    'Add your first product to get started.',
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 20),

                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _addProduct(context);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Product'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // --------------------------------------------
                      // PRODUCTS
                      // --------------------------------------------

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return _productCard(context, product);
                        },
                      );
                    },
                  ),

                  // Extra space above FAB
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
