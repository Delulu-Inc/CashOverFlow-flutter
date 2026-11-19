import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/auth_background.dart';

/// Stripe cancel / failure redirect (`/payment-failed?error=...`).
class PaymentFailedPage extends StatelessWidget {
  const PaymentFailedPage({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 35.0,
              vertical: isMobile ? 40.0 : 60.0,
            ),
            child: GlassCard(
              maxWidth: isMobile ? double.infinity : 650,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 48.0,
                vertical: isMobile ? 32.0 : 60.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Payment Unsuccessful',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 26.0 : 36.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12.0 : 18.0),
                  Text(
                    'We couldn’t process your payment. Please try again or use a different payment method.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : 16.0,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 20.0 : 30.0),
                  Center(
                    child: Container(
                      width: isMobile ? 60 : 80,
                      height: isMobile ? 60 : 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFEF4444),
                          width: isMobile ? 2 : 3,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFFEF4444),
                        size: isMobile ? 35 : 50,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        border: Border.all(color: Colors.white24, width: 1),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash Overflow',
                              style: TextStyle(
                                fontSize: isMobile ? 16.0 : 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$${AppConfig.planPricePerYear}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 22.0 : 28.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  '/year',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12.0 : 14.0,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              errorMessage ??
                                  'Transaction failed. No charges were made to your account.',
                              style: TextStyle(
                                fontSize: isMobile ? 12.0 : 13.0,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 50,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            // The invitation token was remembered before the
                            // Stripe redirect, so the plan page can retry.
                            onPressed: () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.acceptInvite),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.landing,
                                (_) => false,
                              ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
