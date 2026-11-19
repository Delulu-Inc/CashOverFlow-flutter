import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../data/models/checkout_session.dart';
import '../../data/repositories/checkout_repository.dart';

/// Opened from the invitation e-mail (`/accept-invite?token=...`): shows the
/// plan and redirects to the Stripe checkout.
class ActivatePlanPage extends StatefulWidget {
  const ActivatePlanPage({super.key, this.inviteToken});

  final String? inviteToken;

  @override
  State<ActivatePlanPage> createState() => _ActivatePlanPageState();
}

class _ActivatePlanPageState extends State<ActivatePlanPage> {
  bool _isLoading = false;

  final String _planName = AppConfig.planName;
  final double _amount = AppConfig.planPricePerYear.toDouble();

  /// Yearly plan: renews one year after activation.
  String get _renewalDate {
    final now = DateTime.now();
    return DateFormat(
      'MMMM d, yyyy',
      'en_US',
    ).format(DateTime(now.year + 1, now.month, now.day));
  }

  @override
  void initState() {
    super.initState();
    final token = widget.inviteToken;
    if (token != null && token.isNotEmpty) {
      context.read<OnboardingRepository>().rememberInviteToken(token);
    }
  }

  Future<void> _handleProceedToPayment() async {
    setState(() => _isLoading = true);

    final onboardingRepository = context.read<OnboardingRepository>();
    final checkoutRepository = context.read<CheckoutRepository>();

    // "Try again" after a failed payment opens this page without a token.
    final inviteToken =
        widget.inviteToken ?? await onboardingRepository.pendingInviteToken;

    final response = await checkoutRepository.createCheckoutSession(
      CreateCheckoutSessionRequest(
        invitationToken: inviteToken ?? '',
        planName: _planName,
        amount: _amount,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final checkoutUrl = response.checkoutUrl;
    if (response.isSuccess && checkoutUrl != null) {
      final Uri stripeUri = Uri.parse(checkoutUrl);
      bool launched;
      try {
        launched =
            await canLaunchUrl(stripeUri) &&
            await launchUrl(stripeUri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
      if (!launched) {
        _showError('Could not launch Stripe checkout page.');
      }
    } else {
      _showError(response.message ?? 'Failed to create payment session.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
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
                vertical: isMobile ? 32.0 : 40.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Activate your plan',
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
                    isMobile
                        ? 'Review your plan details and proceed to payment to get started.'
                        : 'Review your plan details and proceed to payment to\nget started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : 16.0,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 24.0 : 32.0),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cash Overflow',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _planName,
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${_amount.toInt()}',
                              style: const TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Text(
                              '/year',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Renews on $_renewalDate',
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white54,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Colors.white24, height: 1),
                        ),
                        const _PlanFeatureItem(text: 'Cash-flow forecasting'),
                        const SizedBox(height: 10.0),
                        const _PlanFeatureItem(
                          text: 'Risk detection with explanations',
                        ),
                        const SizedBox(height: 10.0),
                        const _PlanFeatureItem(
                          text: 'AI-powered recommendations',
                        ),
                        const SizedBox(height: 10.0),
                        const _PlanFeatureItem(text: 'What-if simulations'),
                        const SizedBox(height: 10.0),
                        const _PlanFeatureItem(text: 'Role-based permissions'),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 30.0 : 40.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 50,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleProceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Proceed to Secure Payment',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 10.0 : 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanFeatureItem extends StatelessWidget {
  const _PlanFeatureItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, color: Colors.blueAccent, size: 16.0),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.0, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
