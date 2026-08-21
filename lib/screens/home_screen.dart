import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/providers/ThemeProvider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      // backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(title: Text("Shopify")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/banner/banner1.jpg'),
            Text("Buy Now"),
            ElevatedButton(onPressed: () {}, child: Text("Click me ")),
            SwitchListTile(
              title: Text(
                themeProvider.getIsDarkTHeme ? "Dark theme" : "Light Theme",
              ),
              value: themeProvider.getIsDarkTHeme,
              onChanged: (wilson) {
                themeProvider.setDarkTheme(wilson);
                print("Theme state is ${themeProvider.getIsDarkTHeme}");
              },
            ),
          ],
        ),
      ),
    );
  }
}
