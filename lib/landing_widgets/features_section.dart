import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const Color background = Color(0xFF050505);
  static const Color white = Color(0xFFF7F7F7);
  static const Color blue = Color(0xFF2859D9);
  static const Color textGrey = Color(0xFF686868);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.fromLTRB(90, 95, 90, 105),
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 34,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: 'Cash Overflow ',
                  style: TextStyle(
                    color: Color(0xFFE9EEFF),
                  ),
                ),
                TextSpan(
                  text: 'Features',
                  style: TextStyle(
                    color: Color(0xFF1A46C2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Predict smarter, decide with confidence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: white,
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 25),
          const SizedBox(
            width: 680,
            child: Text(
              'From spotting potential cash flow problems to finding solutions and '
              'testing different outcomes. Everything you need to make better '
              'financial decisions, in one platform.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD6D6D6),
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 76),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: FeatureCard(
                  title: 'Predict Problems',
                  description:
                      'Our AI predicts potential cash-flow issues before they happen, and tells you when and why.',
                  child: PredictPreview(),
                ),
              ),
              SizedBox(width: 58),
              Expanded(
                child: FeatureCard(
                  title: 'Suggested Solutions',
                  description:
                      'Get AI-recommended solution with outcomes for each other and discuss reasons with AI chatbot.',
                  child: SolutionsPreview(),
                ),
              ),
              SizedBox(width: 58),
              Expanded(
                child: FeatureCard(
                  title: 'Simulate Outcomes',
                  description:
                      'Run what-if simulations to see how different scenarios could affect your future cash flow.',
                  child: SimulationPreview(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FEATURE CARD
// ============================================================

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 524,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF050505),
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 4),

          // DESCRIPTION
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // INNER PREVIEW
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFC),
                border: Border.all(
                  color: const Color(0xFFB3B3B3),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PREDICT PROBLEMS
// ============================================================

class PredictPreview extends StatelessWidget {
  const PredictPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Risk Forset',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              width: 77,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(1000),
              ),
              child: const Text(
                'High Risk',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          'if we accelerate client A payment by 15 days,\n'
          'our cash position will improve.',
          style: TextStyle(
            color: Color(0xFF4D4D4D),
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 16),

        // 75%
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              '75%',
              style: TextStyle(
                color: Color(0xFF1A46C2),
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Text(
                'Improvement',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          'of a cash shortage in your system',
          style: TextStyle(
            color: Color(0xFF666666),
            fontFamily: 'Inter',
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 16),

        // EXPECTED
        const Row(
          children: [
            Expanded(
              child: Text(
                'Expected in',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontFamily: 'Inter',
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              'Sep 28, 2026',
              style: TextStyle(
                color: Color(0xFF050505),
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Row(
          children: [
            Expanded(
              child: Text(
                'Why',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontFamily: 'Inter',
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              'Rising expenses & delayed payments',
              style: TextStyle(
                color: Color(0xFF333333),
                fontFamily: 'Inter',
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 16,
        ),

        // CHART
        const SizedBox(
          height: 116,
          child: CashFlowChart(),
        ),
      ],
    );
  }
}

// ============================================================
// CASH FLOW CHART
// ============================================================

class CashFlowChart extends StatelessWidget {
  const CashFlowChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pointX = constraints.maxWidth * .72;

        return CustomPaint(
          painter: _CashFlowChartPainter(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sep 28 label
              Positioned(
                left: pointX - 25,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101936),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Sep 28',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CashFlowChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(0, size.height * .65);

    path.cubicTo(
      size.width * .12,
      size.height * .78,
      size.width * .18,
      size.height * .50,
      size.width * .29,
      size.height * .45,
    );

    path.cubicTo(
      size.width * .38,
      size.height * .40,
      size.width * .39,
      size.height * .75,
      size.width * .49,
      size.height * .70,
    );

    path.cubicTo(
      size.width * .58,
      size.height * .64,
      size.width * .58,
      size.height * .38,
      size.width * .72,
      size.height * .36,
    );

    path.cubicTo(
      size.width * .81,
      size.height * .35,
      size.width * .82,
      size.height * .18,
      size.width * .91,
      size.height * .23,
    );

    path.cubicTo(
      size.width * .95,
      size.height * .25,
      size.width * .98,
      size.height * .27,
      size.width,
      size.height * .25,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x223B5EDB),
          Color(0x05000000),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fillPath, fillPaint);

    // LINE
    final linePaint = Paint()
      ..color = const Color(0xFF3159D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, linePaint);

    // DOT
    final dotPaint = Paint()..color = const Color(0xFF3159D8);

    canvas.drawCircle(
      Offset(size.width * .72, size.height * .36),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// SUGGESTED SOLUTIONS
// ============================================================

class SolutionsPreview extends StatelessWidget {
  const SolutionsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Solutions',
          style: TextStyle(
            color: Color(0xFF222222),
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        const SolutionItem(
          title: 'Accelerate client A payment',
          percentage: '↑85%',
        ),

        const SizedBox(height: 8),

        const SolutionItem(
          title: 'Reduce operating expenses',
          percentage: '↑63%',
        ),

        const SizedBox(height: 8),

        const SolutionItem(
          title: 'Renegotiate supplier terms',
          percentage: '↑90%',
        ),

        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFDEE6FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                'assets/icons/smart_boy.svg',
                width: 16,
                height: 16,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                height: 43,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Color(0xFFDEE6FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "What can I explain to you?",
                  style: TextStyle(
                      fontFamily: "inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF050505)),
                ),
              ),
            )
          ],
        ),

        const SizedBox(height: 8),

        // INPUT
        Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFCFCFC),
                  border: Border.all(
                    color: const Color(0xFFB3B3B3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Ask anything..',
                  style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF152B71),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFFDEE6FE),
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// SOLUTION ITEM
// ============================================================

class SolutionItem extends StatelessWidget {
  final String title;
  final String percentage;

  const SolutionItem({
    super.key,
    required this.title,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(
          color: const Color(0xFFD2D2D2),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Estimated impact',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontFamily: 'Inter',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: const TextStyle(
                  color: Color(0xFF26933A),
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Improvement',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontFamily: 'Inter',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SIMULATION
// ============================================================

class SimulationPreview extends StatelessWidget {
  const SimulationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            const Expanded(
              child: Text(
                'What-if Simulation',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDEE6FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Scenario A',
                style: TextStyle(
                  color: Color(0xFF1A46C2),
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          'If we accelerate Client A payment by 15 days, '
          'our cash position will improve and the risk of a '
          'cash shortage will decrease.',
          style: TextStyle(
            color: Color(0xFF4D4D4D),
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        // PROJECTED IMPROVEMENT
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Projected Improvement',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 185,
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCDFEA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.85,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF394CCD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  '85%',
                  style: TextStyle(
                    color: Color(0xFF2331AF),
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Improvement',
                  style: TextStyle(
                    color: Color(0xFF4D4D4D),
                    fontFamily: 'Inter',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        const SimulationResult(
          icon: Icons.payments_outlined,
          text: 'Better cash position in 30 days',
        ),

        const SizedBox(height: 8),

        const SimulationResult(
          icon: Icons.blur_on_rounded,
          text: 'Lower risk of cash shortage',
        ),

        const SizedBox(height: 8),

        const SimulationResult(
          icon: Icons.link,
          text: 'Stronger ability to cover upcoming payments',
        ),

        const SizedBox(height: 8),

        const SimulationResult(
          icon: Icons.thumb_up_alt_outlined,
          text: 'More available cash for planned expenses',
        ),

        const SizedBox(height: 8),

        const SimulationResult(
          icon: Icons.history,
          text: 'Improved short-term liquidity',
        ),
      ],
    );
  }
}

// ============================================================
// SIMULATION RESULT
// ============================================================

class SimulationResult extends StatelessWidget {
  final IconData icon;
  final String text;

  const SimulationResult({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFDEE6FE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF152B71),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
