import 'package:flutter/material.dart';

// Carried over from lisa-v2 frontend/src/index.css + App.jsx
// light: neutral-50, dark: neutral-950, accent purple.
class LisaTheme {
  static const accentLight = Color(0xFFAA3BFF);
  static const accentDark = Color(0xFFC084FC);
  static const teal = Color(0xFF14B8A6);
  static const emerald = Color(0xFF10B981);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accentLight,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAFA),
        foregroundColor: Color(0xFF09090B),
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accentDark,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF09090B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF09090B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
