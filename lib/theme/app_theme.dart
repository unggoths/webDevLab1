import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // --- Palette ---
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFFEDE6);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF8A8A9A);
  static const Color starColor = Color(0xFFFFBF00);
  static const Color divider = Color(0xC0A95EF3);

  // --- Text Styles ---
  static const TextStyle brandLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
    color: accent,
  );

  static const TextStyle productName = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle price = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -1,
  );

  static const TextStyle priceLabel = TextStyle(
    fontSize: 13,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle ratingCount = TextStyle(
    fontSize: 13,
    color: textSecondary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: textPrimary,
  );

  static const TextStyle sizeLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle addToCartButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // --- ThemeData ---
  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      background: background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    useMaterial3: true,
  );
}