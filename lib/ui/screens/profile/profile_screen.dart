import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/ui/screens/%20orders/orders_screen.dart';
import 'package:test_app/ui/screens/wishlist/wishlist_screen.dart';

import '../../../providers/UserProvider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No profile information available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(user: user),

            ProfileSection(
              title: 'Account',
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: user.name,
                  onTap: () {
                    // Open personal information
                  },
                ),

                ProfileMenuTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: user.email,
                ),

                ProfileMenuTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: user.phoneNumber,
                ),

                ProfileMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdersScreen(userId: user.uid),
                      ),
                    );

                    // Navigate to orders
                  },
                ),

                ProfileMenuTile(
                  icon: Icons.favorite_border,
                  title: 'Wishlist',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WishlistScreen(userId: user.uid),
                      ),
                    );
                    // Navigate to wishlist
                  },
                ),
              ],
            ),

            ProfileSection(
              title: 'Account Status',
              children: [
                ProfileMenuTile(
                  icon: Icons.email_outlined,
                  title: 'Email Verification',
                  subtitle: user.emailVerified ? 'Verified' : 'Not verified',
                  trailing: Icon(
                    user.emailVerified
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: user.emailVerified ? Colors.green : Colors.orange,
                  ),
                ),

                ProfileMenuTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone Verification',
                  subtitle: user.phoneVerified ? 'Verified' : 'Not verified',
                  trailing: Icon(
                    user.phoneVerified
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: user.phoneVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
