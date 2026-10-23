import 'package:flutter/material.dart';

/// ReelsPay color palette — dark cinema vibe with gold "money" accents.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0A0A12);
  static const Color surface = Color(0xFF14141F);
  static const Color card = Color(0xFF1C1C2A);
  static const Color stroke = Color(0xFF2A2A3C);

  static const Color gold = Color(0xFFFFC83D);
  static const Color goldDeep = Color(0xFFFF9A2E);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFFF4D8D);
  static const Color green = Color(0xFF34D399);
  static const Color red = Color(0xFFF87171);

  static const Color textPrimary = Color(0xFFF4F4F8);
  static const Color textDim = Color(0xFF9C9CB4);
  static const Color onGold = Color(0xFF231A00);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD965), Color(0xFFFFB020), Color(0xFFFF8A3C)],
  );

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.onGold,
        secondary: AppColors.violet,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.gold.withOpacity(0.14),
        height: 68,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.stroke, thickness: 1),
    );
  }
}
