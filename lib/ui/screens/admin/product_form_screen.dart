import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/category_viewmodel.dart';

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

  String _category = 'Electronics';

  final List<String> categories = [
    'Electronics',
    'Clothing',
    'Shoes',
    'Food',
    'Beauty',
    'Home',
    'Books',
    'Other',
  ];

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

    if (product != null && categories.contains(product.category)) {
      _category = product.category;
    }
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

        // If user selects a new image while editing,
        // the old Cloudinary URL should no longer be used.
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

    final viewModel = context.read<ProductViewModel>();

    final price = double.tryParse(_priceController.text.trim());

    final stock = int.tryParse(_stockController.text.trim());

    if (price == null || stock == null) {
      _showMessage('Please enter valid price and stock values.', isError: true);
      return;
    }

    // For a new product an image is required.
    if (!widget.isEditing && _selectedImage == null) {
      _showMessage('Please select a product image.', isError: true);
      return;
    }

    // If editing, either an existing image or a new image
    // must be available.
    if (widget.isEditing &&
        _selectedImage == null &&
        (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      _showMessage('Please select a product image.', isError: true);
      return;
    }

    final success = await viewModel.saveProduct(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      category: _category,
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
        viewModel.errorMessage ?? 'Failed to save product.',
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();

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
              // IMAGE SECTION
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
                      onPressed: viewModel.isLoading
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

                      onPressed: viewModel.isLoading
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
              // CATEGORY
              // ==================================================
              DropdownButtonFormField<String>(
                value: _category,

                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),

                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),

                onChanged: viewModel.isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _category = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SAVE BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,

                height: 52,

                child: ElevatedButton.icon(
                  onPressed: viewModel.isLoading ? null : _saveProduct,

                  icon: viewModel.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),

                  label: Text(
                    viewModel.isLoading
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
