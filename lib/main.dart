import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/constants/theme_data.dart';
import 'package:test_app/providers/ThemeProvider.dart';
import 'package:test_app/root_screen.dart';
import 'package:test_app/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTHeme,
              context: context,
            ),
            home: RootsScreen(),
          );
        },
      ),
    ),
  );
}
