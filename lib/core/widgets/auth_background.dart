import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full screen darkened photo used behind every authentication / checkout
/// screen.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
        ),
      ),
      child: child,
    );
  }
}

/// Frosted glass card displayed on top of [AuthBackground].
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    required this.padding,
    this.maxWidth = double.infinity,
    this.opacity = 0.75,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassSurface.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
