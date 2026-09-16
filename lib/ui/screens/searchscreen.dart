import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:test_app/ui/screens/product_details_screen.dart';
import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/category_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/wishlist_viewmodel.dart';

import '../../data/models/ category_model.dart';
import '../../data/models/product_model.dart';
import '../../providers/UserProvider.dart';
import 'cartscreen .dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _sortOption = 'Newest';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // FILTER + SEARCH + SORT
  // ==========================================================

  List<ProductModel> _processProducts(List<ProductModel> products) {
    List<ProductModel> result = List.from(products);

    final search = _searchController.text.trim().toLowerCase();

    // SEARCH
    if (search.isNotEmpty) {
      result = result.where((product) {
        final name = product.name.toLowerCase();
        final description = product.description.toLowerCase();

        return name.contains(search) || description.contains(search);
      }).toList();
    }

    // CATEGORY
    if (_selectedCategory != 'All') {
      result = result.where((product) {
        return product.category.toLowerCase() ==
            _selectedCategory.toLowerCase();
      }).toList();
    }

    // SORT
    switch (_sortOption) {
      case 'Name A-Z':
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case 'Price Low':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;

      case 'Price High':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;

      case 'Newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.read<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // ====================================================
          // CART
          // ====================================================
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),

                  if (cart.itemCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
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
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ====================================================
          // SEARCH BAR
          // ====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),

                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,

                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ====================================================
          // CATEGORY + SORT
          // ====================================================
          SizedBox(
            height: 55,
            child: Row(
              children: [
                Expanded(child: _buildCategories()),

                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      setState(() {
                        _sortOption = value;
                      });
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(value: 'Newest', child: Text('Newest')),
                        PopupMenuItem(
                          value: 'Name A-Z',
                          child: Text('Name A-Z'),
                        ),
                        PopupMenuItem(
                          value: 'Price Low',
                          child: Text('Price: Low → High'),
                        ),
                        PopupMenuItem(
                          value: 'Price High',
                          child: Text('Price: High → Low'),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // PRODUCTS
          // ====================================================
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: productViewModel.products,
              builder: (context, snapshot) {
                // LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmer();
                }

                // ERROR
                if (snapshot.hasError) {
                  return _buildError(context, snapshot.error);
                }

                // EMPTY
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmpty();
                }

                final products = _processProducts(snapshot.data!);

                // NO SEARCH RESULTS
                if (products.isEmpty) {
                  return _buildNoResults();
                }

                // PRODUCT GRID
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    return _ProductSearchCard(product: products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DYNAMIC CATEGORIES
  // ==========================================================

  Widget _buildCategories() {
    final categoryViewModel = context.read<CategoryViewModel>();

    return StreamBuilder<List<CategoryModel>>(
      stream: categoryViewModel.categories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load categories'));
        }

        final categories = snapshot.data ?? [];

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _categoryChip('All'),

            ...categories.map((category) => _categoryChip(category.name)),
          ],
        );
      },
    );
  }

  // ==========================================================
  // CATEGORY CHIP
  // ==========================================================

  Widget _categoryChip(String category) {
    final selected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  // ==========================================================
  // SHIMMER
  // ==========================================================

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Container(
                  height: 15,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 15,
                  width: 80,
                  margin: const EdgeInsets.only(left: 12, bottom: 12),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildError(BuildContext context, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50),
            const SizedBox(height: 10),
            Text(
              'Failed to load products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text('$error', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60),
          SizedBox(height: 12),
          Text(
            'No products available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NO RESULTS
  // ==========================================================

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 65,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another search or category',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// PRODUCT CARD
// =================================================================

class _ProductSearchCard extends StatelessWidget {
  final ProductModel product;

  const _ProductSearchCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartViewModel, WishlistViewModel>(
      builder: (context, cart, wishlist, child) {
        final isWishlisted = wishlist.contains(product.id);

        final cartQuantity = cart.quantityOf(product.id);

        // Get the logged-in user.
        final userProvider = context.read<UserProvider>();

        final user = userProvider.user;

        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // IMAGE
              // =================================================
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: _buildProductImage(),
                      ),
                    ),

                    // =================================================
                    // WISHLIST BUTTON
                    // =================================================
                    // =================================================
                    // WISHLIST BUTTON
                    // =================================================
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withOpacity(0.9),
                        shape: const CircleBorder(),
                        child: IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 38,
                          ),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey,
                          ),
                          onPressed: user == null
                              ? null
                              : () async {
                                  if (isWishlisted) {
                                    await wishlist.removeFromWishlist(
                                      userId: user.uid,
                                      productId: product.id,
                                    );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        duration: Duration(milliseconds: 800),
                                        content: Text('Removed from wishlist'),
                                      ),
                                    );
                                  } else {
                                    await wishlist.addToWishlist(
                                      userId: user.uid,
                                      product: product,
                                    );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        duration: Duration(milliseconds: 800),
                                        content: Text('Added to wishlist'),
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // PRODUCT DETAILS
              // =================================================
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'KES ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =========================================
                      // ADD TO CART
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 17,
                          ),
                          label: Text(
                            product.stock <= 0
                                ? 'Out of Stock'
                                : cartQuantity > 0
                                ? 'Add More ($cartQuantity)'
                                : 'Add to Cart',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: product.stock <= 0
                              ? null
                              : () {
                                  cart.addToCart(product);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      content: Text(
                                        '${product.name} added to cart',
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ), // =========================================
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage() {
    if (product.imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 50),
        ),
      );
    }

    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 50),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        );
      },
    );
  }
}
