import 'package:flutter/material.dart';
import 'package:test_app/root_screen.dart';

class EmptyOrdersWidget extends StatelessWidget {
  const EmptyOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 55,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No orders yet',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Your completed and active orders '
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RootsScreen()),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
