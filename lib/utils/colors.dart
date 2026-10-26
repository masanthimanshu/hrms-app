import "package:flutter/material.dart";

/// Curated monochrome and neutral grayscale palette
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Zinc Grays
  static const Color zinc950 = Color(0xFF09090B);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc100 = Color(0xFFF4F4F5);

  // Semantic surfaces
  static const Color scaffoldBg = Color(0xFFF9FAFB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE4E4E7);

  // Status Dots
  static const Color statusActiveDot = Color(0xFF10B981);
  static const Color statusWarningDot = Color(0xFFF59E0B);
  static const Color statusErrorDot = Color(0xFFEF4444);
}
