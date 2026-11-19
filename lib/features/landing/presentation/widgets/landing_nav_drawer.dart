import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Navigation of the landing page on tablets and phones (opened from the
/// hero menu button).
class LandingNavDrawer extends StatelessWidget {
  const LandingNavDrawer({
    super.key,
    required this.onAboutTap,
    required this.onFeaturesTap,
    required this.onFooterTap,
    required this.onPricingTap,
  });

  final VoidCallback onAboutTap;
  final VoidCallback onFeaturesTap;
  final VoidCallback onFooterTap;
  final VoidCallback onPricingTap;

  /// Closes the drawer before running [action].
  VoidCallback _closeThen(BuildContext context, VoidCallback action) {
    return () {
      Navigator.of(context).pop();
      action();
    };
  }

  @override
  Widget build(BuildContext context) {
    const buttonText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'inter',
    );

    return Drawer(
      backgroundColor: AppColors.landingBackground,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 28, height: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'CashFlow',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _DrawerLink('About', onTap: _closeThen(context, onAboutTap)),
              _DrawerLink(
                'Features',
                onTap: _closeThen(context, onFeaturesTap),
              ),
              _DrawerLink('Contact', onTap: _closeThen(context, onFooterTap)),
              _DrawerLink('Pricing', onTap: _closeThen(context, onPricingTap)),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pushNamed(AppRoutes.register);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                  ),
                  child: const Text('Subscribe', style: buttonText),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pushNamed(AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.offWhite,
                    side: const BorderSide(color: AppColors.offWhite),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                  ),
                  child: const Text('Log In', style: buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink(this.title, {required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
