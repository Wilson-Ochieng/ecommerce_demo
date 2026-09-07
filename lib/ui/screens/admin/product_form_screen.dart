import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/category_viewmodel.dart';

import '../../../data/models/ category_model.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  File? _selectedImage;

  String? _existingImageUrl;

  /// Stores the ID of the selected category.
  String? _selectedCategoryId;

  /// Stores the category name for editing/compatibility.
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');

    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );

    _existingImageUrl = product?.imageUrl;

    // IMPORTANT:
    // Your ProductModel currently appears to store the category
    // as a String. We therefore initially keep the category name.
    //
    // The StreamBuilder below will match this name with the
    // dynamically loaded CategoryModel and obtain its ID.
    _selectedCategoryName = product?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    super.dispose();
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);

        // If editing and selecting a new image,
        // don't use the old Cloudinary URL.
        _existingImageUrl = null;
      });
    } catch (e) {
      _showMessage('Failed to select image: $e', isError: true);
    }
  }

  // ============================================================
  // IMAGE OPTIONS
  // ============================================================

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              if (_selectedImage != null ||
                  (_existingImageUrl != null && _existingImageUrl!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.pop(context);

                    setState(() {
                      _selectedImage = null;
                      _existingImageUrl = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productViewModel = context.read<ProductViewModel>();

    final price = double.tryParse(_priceController.text.trim());

    final stock = int.tryParse(_stockController.text.trim());

    if (price == null || stock == null) {
      _showMessage('Please enter valid price and stock values.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // CATEGORY VALIDATION
    // ----------------------------------------------------------

    if (_selectedCategoryName == null ||
        _selectedCategoryName!.trim().isEmpty) {
      _showMessage('Please select a product category.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // IMAGE VALIDATION
    // ----------------------------------------------------------

    if (!widget.isEditing && _selectedImage == null) {
      _showMessage('Please select a product image.', isError: true);
      return;
    }

    if (widget.isEditing &&
        _selectedImage == null &&
        (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      _showMessage('Please select a product image.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // SAVE
    // ----------------------------------------------------------

    final success = await productViewModel.saveProduct(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,

      // We continue sending the CATEGORY NAME because your
      // current ProductViewModel.saveProduct() appears to
      // expect a String category.
      category: _selectedCategoryName!,

      stock: stock,
      image: _selectedImage,
      existingImageUrl: _existingImageUrl,
      createdAt: widget.product?.createdAt,
    );

    if (!mounted) return;

    if (success) {
      _showMessage(
        widget.isEditing
            ? 'Product updated successfully'
            : 'Product added successfully',
      );

      Navigator.pop(context);
    } else {
      _showMessage(
        productViewModel.errorMessage ?? 'Failed to save product.',
        isError: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    }

    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(
        _existingImageUrl!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _emptyImageWidget();
        },
      );
    }

    return _emptyImageWidget();
  }

  Widget _emptyImageWidget() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'No product image selected',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _buildCategoryDropdown(ProductViewModel productViewModel) {
    final categoryViewModel = context.read<CategoryViewModel>();

    return StreamBuilder<List<CategoryModel>>(
      stream: categoryViewModel.categories,

      builder: (context, snapshot) {
        // ------------------------------------------------------
        // LOADING
        // ------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading categories...'),
              ],
            ),
          );
        }

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        if (snapshot.hasError) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load categories',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          );
        }

        // ------------------------------------------------------
        // CATEGORIES
        // ------------------------------------------------------

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            child: const Row(
              children: [
                Icon(Icons.category_outlined, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No categories available. Create a category first.',
                  ),
                ),
              ],
            ),
          );
        }

        // ------------------------------------------------------
        // FIND EDITING CATEGORY
        // ------------------------------------------------------
        //
        // If we are editing an existing product, its category
        // name is matched against the dynamically loaded
        // categories.

        String? currentValue;

        if (_selectedCategoryId != null) {
          final exists = categories.any(
            (category) => category.id == _selectedCategoryId,
          );

          if (exists) {
            currentValue = _selectedCategoryId;
          }
        }

        if (currentValue == null && _selectedCategoryName != null) {
          final matchingCategory = categories.cast<CategoryModel?>().firstWhere(
            (category) =>
                category?.name.trim().toLowerCase() ==
                _selectedCategoryName!.trim().toLowerCase(),
            orElse: () => null,
          );

          if (matchingCategory != null) {
            currentValue = matchingCategory.id;

            // Keep the selected ID synchronized.
            _selectedCategoryId = matchingCategory.id;
          }
        }

        // ------------------------------------------------------
        // DROPDOWN
        // ------------------------------------------------------

        return DropdownButtonFormField<String>(
          value: currentValue,

          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),

          hint: const Text('Select a category'),

          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),

          onChanged: productViewModel.isLoading
              ? null
              : (value) {
                  if (value == null) return;

                  final selectedCategory = categories.firstWhere(
                    (category) => category.id == value,
                  );

                  setState(() {
                    _selectedCategoryId = selectedCategory.id;

                    _selectedCategoryName = selectedCategory.name;
                  });
                },

          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }

            return null;
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Update Product' : 'Add Product'),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // PRODUCT IMAGE
              // ==================================================
              Text(
                'Product Image',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: _buildImagePreview(),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: productViewModel.isLoading
                          ? null
                          : _showImageSourceOptions,

                      icon: const Icon(Icons.add_a_photo),

                      label: const Text('Choose Image'),
                    ),
                  ),

                  if (_selectedImage != null ||
                      (_existingImageUrl != null &&
                          _existingImageUrl!.isNotEmpty))
                    const SizedBox(width: 10),

                  if (_selectedImage != null ||
                      (_existingImageUrl != null &&
                          _existingImageUrl!.isNotEmpty))
                    IconButton(
                      tooltip: 'Remove image',

                      onPressed: productViewModel.isLoading
                          ? null
                          : () {
                              setState(() {
                                _selectedImage = null;

                                _existingImageUrl = null;
                              });
                            },

                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // PRODUCT NAME
              // ==================================================
              TextFormField(
                controller: _nameController,

                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter product name';
                  }

                  if (value.trim().length < 3) {
                    return 'Product name is too short';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DESCRIPTION
              // ==================================================
              TextFormField(
                controller: _descriptionController,

                maxLines: 5,

                decoration: const InputDecoration(
                  labelText: 'Product Description',
                  hintText: 'Describe the product',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter product description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // PRICE
              // ==================================================
              TextFormField(
                controller: _priceController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: '0.00',
                  prefixText: 'KES ',
                  prefixIcon: Icon(Icons.payments),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter product price';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null) {
                    return 'Enter a valid price';
                  }

                  if (price < 0) {
                    return 'Price cannot be negative';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // STOCK
              // ==================================================
              TextFormField(
                controller: _stockController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  hintText: '0',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter stock quantity';
                  }

                  final stock = int.tryParse(value.trim());

                  if (stock == null) {
                    return 'Enter a valid quantity';
                  }

                  if (stock < 0) {
                    return 'Stock cannot be negative';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DYNAMIC CATEGORY
              // ==================================================
              _buildCategoryDropdown(productViewModel),

              const SizedBox(height: 30),

              // ==================================================
              // SAVE BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: productViewModel.isLoading ? null : _saveProduct,

                  icon: productViewModel.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),

                  label: Text(
                    productViewModel.isLoading
                        ? 'Saving Product...'
                        : widget.isEditing
                        ? 'Update Product'
                        : 'Add Product',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
