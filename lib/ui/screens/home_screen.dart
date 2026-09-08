import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/constants/app_constants.dart';

import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/providers/ThemeProvider.dart';
import 'package:test_app/ui/screens/viewmodels/category_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/widgets/product_card.dart';

import '../../data/models/ category_model.dart';

class HomeScreen extends StatefulWidget {
  static const routName = "/HomeScreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Currently selected category.
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final productViewModel = context.read<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: ClipRRect(
          borderRadius: BorderRadius.circular(100),

          child: SizedBox(
            height: 50,
            width: 60,

            child: Image.asset(AppConstants.logo, fit: BoxFit.cover),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // BANNER SWIPER
            // =====================================================
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Swiper(
                    itemBuilder: (context, index) {
                      return Image.asset(
                        AppConstants.bannerImage[index],
                        fit: BoxFit.cover,
                      );
                    },

                    indicatorLayout: PageIndicatorLayout.COLOR,

                    autoplay: true,

                    itemCount: AppConstants.bannerImage.length,

                    pagination: const SwiperPagination(),

                    control: const SwiperControl(),
                  ),
                ),
              ),
            ),

            // =====================================================
            // CATEGORIES TITLE
            // =====================================================
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // =====================================================
            // DYNAMIC CATEGORIES
            // =====================================================
            _buildCategories(),

            const SizedBox(height: 10),

            // =====================================================
            // PRODUCTS TITLE
            // =====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                _selectedCategory == 'All'
                    ? "Latest Products"
                    : "Products in $_selectedCategory",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // =====================================================
            // PRODUCTS
            // =====================================================
            _buildProducts(productViewModel),

            // =====================================================
            // THEME SWITCH
            // =====================================================
            SwitchListTile(
              title: Text(
                themeProvider.getIsDarkTHeme ? "Dark Theme" : "Light Theme",
              ),

              value: themeProvider.getIsDarkTHeme,

              onChanged: (value) {
                themeProvider.setDarkTheme(value);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // DYNAMIC CATEGORY SECTION
  // ==============================================================

  Widget _buildCategories() {
    final categoryViewModel = context.read<CategoryViewModel>();

    return StreamBuilder<List<CategoryModel>>(
      stream: categoryViewModel.categories,

      builder: (context, snapshot) {
        // ----------------------------------------------------------
        // LOADING
        // ----------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // ----------------------------------------------------------
        // ERROR
        // ----------------------------------------------------------

        if (snapshot.hasError) {
          return SizedBox(
            height: 110,
            child: Center(
              child: Text(
                "Failed to load categories",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        // ----------------------------------------------------------
        // GET CATEGORIES
        // ----------------------------------------------------------

        final categories = snapshot.data ?? [];

        // ----------------------------------------------------------
        // CATEGORY LIST
        // ----------------------------------------------------------

        return SizedBox(
          height: 110,

          child: ListView(
            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.symmetric(horizontal: 16),

            children: [
              // ====================================================
              // ALL CATEGORY
              // ====================================================
              _buildCategoryItem(
                name: "All",
                icon: Icons.apps,
                isSelected: _selectedCategory == 'All',

                onTap: () {
                  setState(() {
                    _selectedCategory = 'All';
                  });
                },
              ),

              // ====================================================
              // FIRESTORE CATEGORIES
              // ====================================================
              ...categories.map((category) {
                return _buildCategoryItem(
                  name: category.name,

                  icon: Icons.category_outlined,

                  isSelected: _selectedCategory == category.name,

                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ==============================================================
  // CATEGORY ITEM
  // ==============================================================

  Widget _buildCategoryItem({
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 90,

        margin: const EdgeInsets.only(right: 12),

        child: Column(
          children: [
            // ------------------------------------------------------
            // CATEGORY CIRCLE
            // ------------------------------------------------------
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              height: 62,
              width: 62,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,

                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,

                  width: 2,
                ),
              ),

              child: Icon(
                icon,

                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,

                size: 28,
              ),
            ),

            const SizedBox(height: 7),

            // ------------------------------------------------------
            // CATEGORY NAME
            // ------------------------------------------------------
            Text(
              name,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // PRODUCTS SECTION
  // ==============================================================

  Widget _buildProducts(ProductViewModel productViewModel) {
    return StreamBuilder<List<ProductModel>>(
      stream: productViewModel.products,

      builder: (context, snapshot) {
        // ----------------------------------------------------------
        // LOADING
        // ----------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ----------------------------------------------------------
        // ERROR
        // ----------------------------------------------------------

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // ----------------------------------------------------------
        // NO PRODUCTS
        // ----------------------------------------------------------

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),

              child: Text("No products available"),
            ),
          );
        }

        final products = snapshot.data!;

        // ========================================================
        // FILTER PRODUCTS BY CATEGORY
        // ========================================================

        final filteredProducts = _selectedCategory == 'All'
            ? products
            : products.where((product) {
                return product.category.trim().toLowerCase() ==
                    _selectedCategory.trim().toLowerCase();
              }).toList();

        // ----------------------------------------------------------
        // NO PRODUCTS FOR CATEGORY
        // ----------------------------------------------------------

        if (filteredProducts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(30),

            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 60),

                  const SizedBox(height: 12),

                  Text(
                    "No products found in $_selectedCategory",
                    textAlign: TextAlign.center,

                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                    },

                    child: const Text("View all products"),
                  ),
                ],
              ),
            ),
          );
        }

        // ========================================================
        // PRODUCT GRID
        // ========================================================

        return GridView.builder(
          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          padding: const EdgeInsets.all(12),

          itemCount: filteredProducts.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

            crossAxisSpacing: 12,

            mainAxisSpacing: 12,

            childAspectRatio: 0.62,
          ),

          itemBuilder: (context, index) {
            final product = filteredProducts[index];

            return ProductCard(product: product);
          },
        );
      },
    );
  }
}
