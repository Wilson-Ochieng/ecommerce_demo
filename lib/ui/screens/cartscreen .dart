import 'package:flutter/material.dart';

import 'package:test_app/ui/screens/widgets/cart_bottom_sheet.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CartBottomSheet());
  }
}
