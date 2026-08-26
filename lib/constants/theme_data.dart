import 'package:flutter/material.dart';

import 'app_colors.dart';

class Styles {
  // ============================================================
  // GLOBAL DESIGN CONSTANTS
  // ============================================================

  static const String fontFamily = 'Mulish';

  static const double borderRadius = 12;

  static const double buttonHeight = 52;

  // ============================================================
  // THEME DATA
  // ============================================================

  static ThemeData themeData({
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    final primaryColor = isDarkTheme
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondaryColor = isDarkTheme
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final scaffoldColor = isDarkTheme
        ? AppColors.darkScaffoldColor
        : AppColors.lightScaffoldColor;

    final textColor = isDarkTheme
        ? AppColors.darkTextColor
        : AppColors.lightTextColor;

    final headingColor = isDarkTheme
        ? AppColors.darkHeadingColor
        : AppColors.lightHeadingColor;

    final secondaryTextColor = isDarkTheme
        ? AppColors.darkSecondaryTextColor
        : AppColors.lightSecondaryTextColor;

    final hintColor = isDarkTheme
        ? AppColors.darkHintColor
        : AppColors.lightHintColor;

    final inputColor = isDarkTheme
        ? AppColors.darkInputColor
        : AppColors.lightInputColor;

    final borderColor = isDarkTheme
        ? AppColors.darkBorderColor
        : AppColors.lightBorderColor;

    final appBarColor = isDarkTheme
        ? AppColors.darkAppBarColor
        : AppColors.lightAppBarColor;

    // ==========================================================
    // COLOR SCHEME
    // ==========================================================

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDarkTheme
          ? Brightness.dark
          : Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: isDarkTheme
          ? AppColors.darkSurfaceColor
          : AppColors.lightSurfaceColor,
      error: AppColors.errorColor,
    );

    return ThemeData(
      // ========================================================
      // BASIC THEME
      // ========================================================

      useMaterial3: true,

      brightness: isDarkTheme
          ? Brightness.dark
          : Brightness.light,

      fontFamily: fontFamily,

      scaffoldBackgroundColor: scaffoldColor,

      colorScheme: colorScheme,

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,

        foregroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        surfaceTintColor: Colors.transparent,

        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),

      // ========================================================
      // TEXT THEME
      // ========================================================

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: headingColor,
        ),

        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: headingColor,
        ),

        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: headingColor,
        ),

        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: headingColor,
        ),

        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: headingColor,
        ),

        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: headingColor,
        ),

        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: headingColor,
        ),

        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),

        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),

        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),

        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),

        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
        ),

        labelLarge: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),

        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),

        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor,
        ),
      ),

      // ========================================================
      // CARD
      // ========================================================

      cardTheme: CardThemeData(
        elevation: 0,

        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius,
          ),
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),

        color: isDarkTheme
            ? AppColors.darkCardColor
            : AppColors.lightCardColor,

        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: inputColor,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: hintColor,
          fontSize: 14,
        ),

        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: secondaryTextColor,
          fontSize: 14,
        ),

        prefixIconColor: secondaryTextColor,

        suffixIconColor: secondaryTextColor,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            borderRadius,
          ),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            borderRadius,
          ),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            borderRadius,
          ),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            borderRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.errorColor,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            borderRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.errorColor,
            width: 2,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,

          foregroundColor: isDarkTheme
              ? AppColors.darkButtonTextColor
              : AppColors.lightButtonTextColor,

          minimumSize: const Size(
            double.infinity,
            buttonHeight,
          ),

          elevation: 0,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              borderRadius,
            ),
          ),

          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,

          minimumSize: const Size(
            double.infinity,
            buttonHeight,
          ),

          side: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              borderRadius,
            ),
          ),

          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,

          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme: CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return primaryColor;
            }

            return Colors.transparent;
          },
        ),
      ),

      // ========================================================
      // PROGRESS INDICATOR
      // ========================================================

      progressIndicatorTheme:
          ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: isDarkTheme
            ? AppColors.darkSurfaceColor
            : AppColors.lightHeadingColor,

        contentTextStyle:
            const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 14,
        ),

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            borderRadius,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD GRADIENT
  // ============================================================

  static LinearGradient cardGradient({
    required bool isDarkTheme,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkTheme
          ? AppColors.darkCardGradient
          : AppColors.lightCardGradient,
    );
  }

  // ============================================================
  // PRIMARY GRADIENT
  // ============================================================

  static LinearGradient primaryGradient({
    required bool isDarkTheme,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkTheme
          ? AppColors.darkPrimaryGradient
          : AppColors.lightPrimaryGradient,
    );
  }

  // ============================================================
  // BUTTON GRADIENT
  // ============================================================

  static LinearGradient buttonGradient({
    required bool isDarkTheme,
  }) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDarkTheme
          ? AppColors.darkButtonGradient
          : AppColors.lightButtonGradient,
    );
  }
}