import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'helpdesk_theme_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.neutral50,
      surfaceContainer: AppColors.neutral100,
      surfaceContainerHigh: AppColors.neutral200,
      surfaceContainerHighest: AppColors.neutral300,
      outline: AppColors.neutral200,
      outlineVariant: AppColors.neutral100,
      primary: AppColors.neutral900,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Roboto',
      extensions: const [
        HelpdeskThemeTokens.light,
      ],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral950,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral950,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.neutral200, width: 1),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.neutral400,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.neutral600,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.neutral900, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.statusEscalated),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.statusEscalated, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.neutral900,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.neutral900,
          side: const BorderSide(color: AppColors.neutral200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      surfaceContainerLowest: AppColors.backgroundDark,
      surfaceContainerLow: const Color(0xFF18181B),
      surfaceContainer: const Color(0xFF27272A),
      surfaceContainerHigh: const Color(0xFF3F3F46),
      surfaceContainerHighest: const Color(0xFF52525B),
      outline: const Color(0xFF27272A),
      outlineVariant: const Color(0xFF18181B),
      primary: Colors.white,
      onPrimary: AppColors.neutral950,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Roboto',
      extensions: const [
        HelpdeskThemeTokens.dark,
      ],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF27272A), width: 1),
        ),
        color: AppColors.surfaceDark,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF27272A),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF71717A),
          fontWeight: FontWeight.normal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF27272A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF27272A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}
