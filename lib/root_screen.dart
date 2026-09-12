import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:test_app/ui/screens/auth/login_screen.dart';
import 'package:test_app/ui/screens/cartscreen%20.dart';
import 'package:test_app/ui/screens/home_screen.dart';
import 'package:test_app/ui/screens/profilescreen.dart';
import 'package:test_app/ui/screens/searchscreen.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/cart_viewmodel.dart';

class RootsScreen extends StatefulWidget {
  static const routName = "/RootsScreen";

  const RootsScreen({super.key});

  @override
  State<RootsScreen> createState() => _RootsScreenState();
}

class _RootsScreenState extends State<RootsScreen> {
  late final List<Widget> screens;
  late final PageController controller;

  int currentScreen = 0;

  @override
  void initState() {
    super.initState();

    screens = [
      const HomeScreen(),
      const SearchScreen(),
      const CartScreen(),
      const Profilescreen(),
    ];

    controller = PageController(initialPage: currentScreen);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ============================================================
  // CHANGE SCREEN
  // ============================================================

  void _changeScreen(int index) {
    setState(() {
      currentScreen = index;
    });

    controller.jumpToPage(index);
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final viewModel = context.read<AuthStartupViewModel>();

    final success = await viewModel.logout();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to sign out')),
      );
    }
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = currentScreen == index;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: selected,
      onTap: () {
        _changeScreen(index);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        automaticallyImplyLeading: false,

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: const Text("Shopify"),
      ),

      // ========================================================
      // DRAWER
      // ========================================================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Shopify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // HOME
            _drawerItem(
              context: context,
              icon: Iconsax.home,
              title: 'Home',
              index: 0,
            ),

            // SEARCH
            _drawerItem(
              context: context,
              icon: Iconsax.search_favorite,
              title: 'Search',
              index: 1,
            ),

            // ==================================================
            // CART DRAWER ITEM
            // ==================================================
            Consumer<CartViewModel>(
              builder: (context, cart, child) {
                return ListTile(
                  leading: const Icon(Iconsax.bag2),

                  title: const Text('Cart'),

                  trailing: cart.itemCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,

                  onTap: () {
                    _changeScreen(2);
                    Navigator.pop(context);
                  },
                );
              },
            ),

            // PROFILE
            _drawerItem(
              context: context,
              icon: Iconsax.profile,
              title: 'Profile',
              index: 3,
            ),

            const Divider(),

            // LOGOUT
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _logout();
              },
            ),
          ],
        ),
      ),

      // ========================================================
      // PAGE VIEW
      // ========================================================
      body: PageView(
        controller: controller,

        physics: const NeverScrollableScrollPhysics(),

        children: screens,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: Consumer<CartViewModel>(
        builder: (context, cart, child) {
          return NavigationBar(
            selectedIndex: currentScreen,

            backgroundColor: Theme.of(context).scaffoldBackgroundColor,

            height: kBottomNavigationBarHeight,

            onDestinationSelected: (index) {
              _changeScreen(index);
            },

            destinations: [
              // ==================================================
              // HOME
              // ==================================================
              const NavigationDestination(
                selectedIcon: Icon(Iconsax.activity),
                icon: Icon(Iconsax.activity),
                label: "Home",
              ),

              // ==================================================
              // SEARCH
              // ==================================================
              const NavigationDestination(
                selectedIcon: Icon(Iconsax.search_favorite),
                icon: Icon(Iconsax.search_favorite),
                label: "Search",
              ),

              // ==================================================
              // CART WITH BADGE
              // ==================================================
              NavigationDestination(
                selectedIcon: _CartIcon(
                  icon: Iconsax.bag2,
                  count: cart.itemCount,
                ),

                icon: _CartIcon(icon: Iconsax.bag2, count: cart.itemCount),

                label: "Cart",
              ),

              // ==================================================
              // PROFILE
              // ==================================================
              const NavigationDestination(
                selectedIcon: Icon(Iconsax.profile),
                icon: Icon(Iconsax.profile),
                label: "Profile",
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================================================================
// CART ICON WITH BADGE
// ================================================================

class _CartIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _CartIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,

      label: Text(count > 99 ? '99+' : '$count'),

      child: Icon(icon),
    );
  }
}
