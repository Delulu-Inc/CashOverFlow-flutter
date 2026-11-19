import 'package:flutter/painting.dart';

/// Colors shared by several features.
///
/// Values are taken 1:1 from the approved Figma design. Feature specific
/// colors stay next to the widgets that use them.
abstract final class AppColors {
  // Brand
  static const Color brandBlue = Color(0xFF1A46C2);
  static const Color primary = Color(0xFF1D4ED8);

  // Surfaces
  static const Color appBackground = Color(0xFFF8FAFC);
  static const Color landingBackground = Color(0xFF07080C);
  static const Color dashboardBackground = Color(0xFFE6E6E6);
  static const Color sidebarBackground = Color(0xFF0A0F1D);
  static const Color sidebarActive = Color(0xFF1E293B);
  static const Color glassSurface = Color(0xFF232528);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color offWhite = Color(0xFFFCFCFC);
}
