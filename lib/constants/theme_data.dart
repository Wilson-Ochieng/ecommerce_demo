import 'package:flutter/material.dart';

import 'app_colors.dart';

class Styles {
  static ThemeData themeData({
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    final primaryColor = isDarkTheme
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return ThemeData(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,

      scaffoldBackgroundColor: isDarkTheme
          ? AppColors.darkScaffoldColor
          : AppColors.lightScaffoldColor,

      cardColor: isDarkTheme
          ? const Color.fromARGB(100, 78, 89, 67)
          : AppColors.lightCardColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
