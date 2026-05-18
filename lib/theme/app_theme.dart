import 'package:db_notes/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const double containerPadding = 24;
  static const double cardPadding = 20;
  static const double gutter = 16;
  static const double cardRadius = 20;
  static const double searchRadius = 14;
  static const double fabRadius = 18;
  static const double fabSize = 64;

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
      onPrimary: isDark ? const Color(0xFF2900A0) : Colors.white,
      primaryContainer:
          isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimary,
      onPrimaryContainer:
          isDark ? AppColors.darkOnPrimaryContainer : Colors.white,
      secondary: const Color(0xFF5FDACB),
      onSecondary: const Color(0xFF003732),
      tertiary: const Color(0xFFFFB871),
      onTertiary: const Color(0xFF4A2800),
      error: isDark ? const Color(0xFFFFB4AB) : AppColors.lightDelete,
      onError: Colors.white,
      errorContainer:
          isDark ? AppColors.darkErrorContainer : AppColors.lightDelete,
      onErrorContainer:
          isDark ? AppColors.darkOnErrorContainer : Colors.white,
      surface: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      onSurface: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      onSurfaceVariant: isDark
          ? AppColors.darkOnSurfaceVariant
          : AppColors.lightOnSurfaceVariant,
      outline: isDark ? const Color(0xFF928EA0) : const Color(0xFF928EA0),
      outlineVariant: isDark
          ? AppColors.darkOutlineVariant
          : AppColors.darkOutlineVariant.withValues(alpha: 0.35),
      surfaceContainerHighest:
          isDark ? AppColors.darkCard : AppColors.lightCard,
      surfaceContainerHigh:
          isDark ? AppColors.darkSearch : AppColors.lightSearch,
      surfaceContainer: isDark ? AppColors.darkNav : AppColors.lightNav,
    );

    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).copyWith(
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        letterSpacing: -0.2,
        color: base.onSurface,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: base.onSurface,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: base.onSurface,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: base.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.5,
        color: base.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: base,
      scaffoldBackgroundColor: base.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: base.surface,
        foregroundColor: base.primary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: IconThemeData(color: base.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: base.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: isDark
              ? BorderSide.none
              : BorderSide(color: base.outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: base.primary.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: base.onSurfaceVariant.withValues(alpha: isDark ? 1 : 0.7),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkModal : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
    );
  }
}
