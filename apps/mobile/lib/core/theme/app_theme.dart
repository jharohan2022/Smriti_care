import 'package:flutter/material.dart';

/// Accessibility constants for the patient (zero-literacy) UI.
class A11y {
  /// Minimum interactive target for patient screens. WCAG asks for 44dp; dementia
  /// patients with motor decline need far more — we use 150dp+ per the design spec.
  static const double patientTapTarget = 160;

  /// Patient body/label text is deliberately huge.
  static const double patientHeadline = 40;
  static const double patientLabel = 30;

  /// High-contrast, warm, calm palette (avoids blues that read as "cold"/clinical
  /// for the patient; ASHA/clinical surfaces are cooler).
  static const Color patientPrimary = Color(0xFF00695C); // teal 800
  static const Color patientOnPrimary = Colors.white;
  static const Color patientSurface = Color(0xFFFFF8E1); // warm cream
}

class AppTheme {
  /// Patient theme: oversized type, high contrast, minimum-size buttons.
  static ThemeData get patient {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: A11y.patientPrimary,
        primary: A11y.patientPrimary,
        surface: A11y.patientSurface,
      ),
      scaffoldBackgroundColor: A11y.patientSurface,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(fontSize: A11y.patientHeadline, fontWeight: FontWeight.w800),
        titleLarge: const TextStyle(fontSize: A11y.patientLabel, fontWeight: FontWeight.w700),
        bodyLarge: const TextStyle(fontSize: 26),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(A11y.patientTapTarget, A11y.patientTapTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontSize: A11y.patientLabel, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  /// ASHA theme: standard clinical density, cool palette, readable but compact.
  static ThemeData get asha {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
    );
  }
}
