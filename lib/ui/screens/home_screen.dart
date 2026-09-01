import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/data/models/product_model.dart';
import 'package:test_app/providers/ThemeProvider.dart';
import 'package:test_app/ui/screens/viewmodels/product_viewmodel.dart';
import 'package:test_app/ui/screens/widgets/product_card.dart';

// Product MVVM imports

class HomeScreen extends StatefulWidget {
  static const routName = "/HomeScreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Get ProductViewModel
    final productViewModel = context.read<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Shopify")),

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
            // SECTION TITLE
            // =====================================================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "Latest Products",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // =====================================================
            // PRODUCTS FROM FIRESTORE
            // =====================================================
            StreamBuilder<List<ProductModel>>(
              stream: productViewModel.products,

              builder: (context, snapshot) {
                // LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // ERROR
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
                }

                // NO PRODUCTS
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("No products available"),
                    ),
                  );
                }

                final products = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,

                  // Important because we are inside
                  // SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),

                  padding: const EdgeInsets.all(12),

                  itemCount: products.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 12,

                    mainAxisSpacing: 12,

                    childAspectRatio: 0.62,
                  ),

                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
            ),

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

                debugPrint(
                  "Theme state is "
                  "${themeProvider.getIsDarkTHeme}",
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
