import 'package:flutter/widgets.dart';

/// Width breakpoints shared by every screen.
///
/// The Figma frames are designed for desktop (1440px). Every screen keeps the
/// original desktop design from its desktop breakpoint upwards and only
/// adapts the layout below it, so the approved design is never altered on
/// large screens.
abstract final class Breakpoints {
  /// Below this width the device is treated as a phone.
  static const double mobile = 600;

  /// Below this width two-column content is stacked.
  static const double tablet = 900;

  /// From this width the dashboard sidebar is permanently visible.
  static const double laptop = 1024;

  /// From this width the landing page renders the original Figma layout.
  static const double desktop = 1200;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < Breakpoints.mobile;

  bool get isDesktop => screenWidth >= Breakpoints.desktop;
}

/// Helpers to pick a value for the current width.
abstract final class Responsive {
  /// Returns [mobile] below [Breakpoints.mobile], [desktop] from
  /// [desktopFrom] upwards and [tablet] (defaults to [desktop]) in between.
  static T value<T>(
    double width, {
    required T mobile,
    T? tablet,
    required T desktop,
    double desktopFrom = Breakpoints.desktop,
  }) {
    if (width < Breakpoints.mobile) return mobile;
    if (width < desktopFrom) return tablet ?? desktop;
    return desktop;
  }

  /// Horizontal page gutter used by the landing sections.
  ///
  /// Desktop keeps the 96px gutter from the Figma frame.
  static double landingGutter(double width, {double desktop = 96}) {
    return value(width, mobile: 20.0, tablet: 40.0, desktop: desktop);
  }
}
