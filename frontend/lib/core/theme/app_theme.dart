import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'helpdesk_theme_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF8FAFC),
      surfaceContainer: const Color(0xFFF1F5F9),
      surfaceContainerHigh: const Color(0xFFE2E8F0),
      surfaceContainerHighest: const Color(0xFFCBD5E1),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFFE2E8F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'Roboto',
      extensions: const [
        HelpdeskThemeTokens.light,
      ],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.statusEscalated),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.statusEscalated, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F172A),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(false),
        trackVisibility: const WidgetStatePropertyAll(false),
        radius: const Radius.circular(4),
        thickness: const WidgetStatePropertyAll(6),
        thumbColor: WidgetStatePropertyAll(const Color(0xFFCBD5E1).withValues(alpha: 0.8)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F172A),
      surfaceContainerLowest: const Color(0xFF020617),
      surfaceContainerLow: const Color(0xFF0B132B),
      surfaceContainer: const Color(0xFF1E293B),
      surfaceContainerHigh: const Color(0xFF334155),
      surfaceContainerHighest: const Color(0xFF475569),
      outline: const Color(0xFF475569),
      outlineVariant: const Color(0xFF334155),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF020617),
      fontFamily: 'Roboto',
      extensions: const [
        HelpdeskThemeTokens.dark,
      ],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        color: const Color(0xFF0F172A),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E293B),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.statusEscalated),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.statusEscalated, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: Color(0xFF475569)),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        side: const BorderSide(color: Color(0xFF334155)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCBD5E1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 4,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(false),
        trackVisibility: const WidgetStatePropertyAll(false),
        radius: const Radius.circular(4),
        thickness: const WidgetStatePropertyAll(6),
        thumbColor: WidgetStatePropertyAll(const Color(0xFF475569).withValues(alpha: 0.8)),
      ),
    );
  }
}
