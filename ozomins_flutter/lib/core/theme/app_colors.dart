import 'package:flutter/material.dart';

/// Ozomins Blinkit-Inspired Design System
/// Quick-commerce high-contrast, vibrant palette.
class AppColors {
  AppColors._();

  // ── Brand Colors (Primary) ──────────────────────────────────
  static const Color primary = Color(0xFFF8CB46); // Blinkit Yellow
  static const Color primaryContainer = Color(0xFFE5B833);
  static const Color primaryGreen = Color(0xFF0C831F); // Blinkit Deep Green
  static const Color mintAccent = Color(0xFFE8F5E9);
  static const Color onPrimary = Color(0xFF000000); // Black text on yellow
  static const Color darkGreen = Color(0xFF075E13);

  // ── Surface Tonal Hierarchy (Clean & White) ────────────
  static const Color scaffoldBg = Color(0xFFF5F7F9); // Very light grey background
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFF1F3F5);
  static const Color surfaceContainerHigh = Color(0xFFE9ECEF);
  static const Color surfaceContainerHighest = Color(0xFFDEE2E6);
  static const Color surfaceBright = Color(0xFFFFFFFF);

  // ── Legacy aliases ──────────────────────────────────────────
  static const Color cardBg = surface;
  static const Color cardBgElevated = surfaceContainerHigh;
  static const Color surfaceBorder = Color(0xFFE0E0E0);
  static const Color surfaceBorderLight = Color(0xFFF0F0F0);

  // ── Borders ──────────────────────────────────────────────────
  static const Color outlineVariant = Color(0xFFE0E0E0);
  static const Color outline = Color(0xFFBDBDBD);

  // ── Text ────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1E1E1E); // Crisp Black
  static const Color onSurfaceVariant = Color(0xFF424242);
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = Color(0xFF757575);
  static const Color textOnGreen = Color(0xFFFFFFFF);

  // ── Secondary ──────────────────────────────────────────────
  static const Color secondary = Color(0xFF9E9E9E);
  static const Color secondaryContainer = Color(0xFFEEEEEE);

  // ── Tertiary (Speed/Urgency) ──────────────────────────────
  static const Color tertiary = Color(0xFFFF5252); // Red for urgency
  static const Color tertiaryContainer = Color(0xFFFFCDD2);
  static const Color onTertiaryFixed = Color(0xFFFFFFFF);

  // ── Semantic ────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningAmber = Color(0xFFFFA000);
  static const Color infoCyan = Color(0xFF0288D1);

  // ── Green Glow Shadow ──────────────────────────────────────
  static const Color greenGlow = Color(0x1A0C831F); // 10% opacity green

  // ── Worker avatar gradients ────────────────────────────────
  static const List<Color> avatarGreenGrad = [
    Color(0xFF0C831F),
    Color(0xFF388E3C),
  ];
  static const List<Color> avatarPurpleGrad = [
    Color(0xFF7C4DFF),
    Color(0xFFB388FF),
  ];
  static const List<Color> avatarOrangeGrad = [
    Color(0xFFFF6D00),
    Color(0xFFFFAB40),
  ];
  static const List<Color> avatarBlueGrad = [
    Color(0xFF00B0FF),
    Color(0xFF80D8FF),
  ];

  // ── Brand gradient ─────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── CTA gradient (jeweled button) ─────────────────────────
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
