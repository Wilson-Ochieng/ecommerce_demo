import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/ category_model.dart';
import '../viewmodels/category_viewmodel.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  Future<void> _showCategoryDialog(
    BuildContext context, {
    CategoryModel? category,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');

    final viewModel = context.read<CategoryViewModel>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(category == null ? 'Add Category' : 'Edit Category'),

              content: TextField(
                controller: controller,
                autofocus: true,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Electronics',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = controller.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a category name.'),
                              ),
                            );
                            return;
                          }

                          // Prevent duplicate clicks
                          setDialogState(() {
                            isSaving = true;
                          });

                          bool success;

                          if (category == null) {
                            success = await viewModel.addCategory(name);
                          } else {
                            success = await viewModel.updateCategory(
                              category.id,
                              name,
                            );
                          }

                          // Make sure the dialog is still mounted
                          if (!context.mounted) return;

                          if (success) {
                            // Close the dialog first
                            Navigator.of(dialogContext).pop();

                            // Show message after the dialog closes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    category == null
                                        ? 'Category created successfully.'
                                        : 'Category updated successfully.',
                                  ),
                                ),
                              );
                            });
                          } else {
                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  viewModel.errorMessage ?? 'Operation failed.',
                                ),
                              ),
                            );
                          }
                        },

                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(category == null ? 'Create' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _deleteCategory(
    BuildContext context,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),

          content: Text('Are you sure you want to delete "${category.name}"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final viewModel = context.read<CategoryViewModel>();

    final success = await viewModel.deleteCategory(category.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Category deleted successfully.'
              : viewModel.errorMessage ?? 'Failed to delete category.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT:
    // Use read(), NOT watch().
    //
    // The StreamBuilder below listens to category changes.
    // We don't need the entire screen rebuilding whenever
    // CategoryViewModel calls notifyListeners().
    final viewModel = context.read<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Category Management')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCategoryDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),

      body: StreamBuilder<List<CategoryModel>>(
        stream: viewModel.categories,

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),

                    const SizedBox(height: 16),

                    const Text(
                      'Failed to load categories.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text('${snapshot.error}', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];

          // Empty
          if (categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64),

                  SizedBox(height: 16),

                  Text(
                    'No categories available.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 8),

                  Text('Create your first category.'),
                ],
              ),
            );
          }

          // Categories
          return ListView.separated(
            padding: const EdgeInsets.all(16),

            itemCount: categories.length,

            separatorBuilder: (_, __) => const SizedBox(height: 8),

            itemBuilder: (context, index) {
              final category = categories[index];

              final firstLetter = category.name.trim().isNotEmpty
                  ? category.name.trim().substring(0, 1).toUpperCase()
                  : '?';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(firstLetter)),

                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Text('Category ID: ${category.id}'),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit Category',

                        icon: const Icon(Icons.edit_outlined),

                        onPressed: () {
                          _showCategoryDialog(context, category: category);
                        },
                      ),

                      IconButton(
                        tooltip: 'Delete Category',

                        icon: const Icon(Icons.delete_outline),

                        onPressed: () {
                          _deleteCategory(context, category);
                        },
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
}
