import 'dart:ui';
import 'package:flutter/material.dart';

class ActivatePlanPage extends StatelessWidget {
  const ActivatePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.jpg'),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 35.0,
              vertical: isMobile ? 40.0 : 60.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 650,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 48.0,
                    vertical: isMobile ? 32.0 : 40.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232528).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // العنوان الرئيسي
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

                      // النص الوصفي
                      Text(
                        'Review your plan details and proceed to payment to\nget started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : 16.0,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: isMobile ? 24.0 : 32.0),

                      // صندوق تفاصيل الخطة (Plan Details Card)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
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
                            const Text(
                              'Annual Plan',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: const [
                                Text(
                                  '\$499',
                                  style: TextStyle(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  '/year',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Renews on September 9, 2027',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white54,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(color: Colors.white24, height: 1),
                            ),
                            // قائمة المميزات (Features List)
                            const _PlanFeatureItem(
                              text: 'Cash-flow forecasting',
                            ),
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
                            const _PlanFeatureItem(
                              text: 'Role-based permissions',
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isMobile ? 30.0 : 40.0),

                      // زر "Proceed to Secure Payment"
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 0 : 50,
                        ),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
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
        ),
      ),
    );
  }
}

// ويدجت فرعية لعناصر الميزات الموجودة داخل الخطة
// Helper widget for plan feature items
class _PlanFeatureItem extends StatelessWidget {
  final String text;

  const _PlanFeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, color: Colors.blueAccent, size: 16.0),
        const SizedBox(width: 10.0),
        Text(
          text,
          style: const TextStyle(fontSize: 13.0, color: Colors.white70),
        ),
      ],
    );
  }
}
