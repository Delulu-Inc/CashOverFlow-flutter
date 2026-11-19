import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/auth_background.dart';

/// Stripe success redirect (`/payment-success?session_id=...`).
///
/// When the API callback (`/v1/Checkout/callback`) forwards the invitation
/// `token` / `orgId`, they are handed over to the set-password step.
class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key, this.sessionId, this.token, this.orgId});

  final String? sessionId;
  final String? token;
  final String? orgId;

  String get _setPasswordRoute {
    final params = <String, String>{'token': ?token, 'orgId': ?orgId};
    return Uri(
      path: AppRoutes.setPassword,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }

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
                    'You’re all set!',
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
                    'Your subscription has been activated successfully.',
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
                          color: Colors.white,
                          width: isMobile ? 2 : 3,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: isMobile ? 35 : 50,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                    child: _PlanSummaryCard(
                      isMobile: isMobile,
                      message:
                          'Everything you need to predict, understand, and stay ahead of your cash.',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 50,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(_setPasswordRoute),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

/// Plan recap shared by the payment result pages.
class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.isMobile, required this.message});

  final bool isMobile;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              message,
              style: TextStyle(
                fontSize: isMobile ? 12.0 : 13.0,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
