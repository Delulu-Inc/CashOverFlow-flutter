import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/responsive/responsive.dart';

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key});

  static const List<WhyUsCard> _whyUsCards = [
    WhyUsCard(
      path: 'assets/icons/predict.svg',
      title: 'Predict',
      desc: 'Identify potential cash shortages early with clear explanations.',
    ),
    WhyUsCard(
      path: 'assets/icons/simulate.svg',
      title: 'Simulation',
      desc: 'Test different scenarios and understand their possible impact.',
    ),
    WhyUsCard(
      path: 'assets/icons/solution.svg',
      title: 'Solutions',
      desc: 'Receive AI-powered recommendations tailored to your situation.',
    ),
    WhyUsCard(
      path: 'assets/icons/syn.svg',
      title: 'Sync',
      desc: 'Keep forecasts aligned with your latest financial data.',
    ),
    WhyUsCard(
      path: 'assets/icons/Users.svg',
      title: 'Permission',
      desc: 'Securely give the right people access to your workspace.',
    ),
  ];

  /// Tablets & phones: text above the image, cards in a grid.
  Widget _buildCompact(BuildContext context) {
    final double width = context.screenWidth;
    final bool isMobile = width < Breakpoints.mobile;
    final double gutter = Responsive.landingGutter(width);

    return Container(
      width: double.infinity,
      color: const Color(0xFF07080C),
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: isMobile ? 56 : 72,
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text: 'About ',
                      style: TextStyle(color: Color(0xFFFCFCFC)),
                    ),
                    TextSpan(
                      text: 'Cash Overflow',
                      style: TextStyle(color: Color(0xFF1A46C2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Built to help businesses stay ahead of their cash.',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: const Color(0xFFFCFCFC),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cash Overflow is an AI-powered platform that helps businesses track liquidity, forecast cash flow, identify risks, and make smarter financial decisions—all from one clear view.',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: const Color(0xFFE6E6E6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 2500 / 1846,
                  child: Image.asset(
                    'assets/images/aboutus.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFF11141A)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 64 : 96),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: isMobile ? 30 : 36,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                height: 1.5,
              ),
              children: const [
                TextSpan(
                  text: 'Why Choose ',
                  style: TextStyle(color: Color(0xFFFCFCFC)),
                ),
                TextSpan(
                  text: 'US',
                  style: TextStyle(color: Color(0xFF1A46C2)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your business shouldn\'t have to wait for a cash shortage to happen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFCFCFC),
              fontSize: isMobile ? 18 : 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 16;
              final int columns = constraints.maxWidth >= 720
                  ? 3
                  : (constraints.maxWidth >= 360 ? 2 : 1);
              final double cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: [
                  for (final card in _whyUsCards)
                    SizedBox(width: cardWidth, child: card),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.screenWidth < Breakpoints.desktop) {
      return _buildCompact(context);
    }

    // Desktop: original Figma layout.
    return Container(
      width: double.infinity,
      color: const Color(0xFF07080C),
      padding: const EdgeInsets.fromLTRB(96, 80, 96, 80),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'About ',
                            style: TextStyle(color: Color(0xFFFCFCFC)),
                          ),
                          TextSpan(
                            text: 'Cash Overflow',
                            style: TextStyle(color: Color(0xFF1A46C2)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Built to help businesses\n'
                      'stay ahead of their cash.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: Color(0xFFFCFCFC),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cash Overflow is an AI-powered platform '
                      'that helps businesses track liquidity, '
                      'forecast cash flow, identify risks, and '
                      'make smarter financial decisions—all '
                      'from one clear view.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        color: Color(0xFFE6E6E6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 78),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/aboutus.png',
                    height: 411,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 411,
                        color: const Color(0xFF11141A),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white24,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 126),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'Why Choose ',
                  style: TextStyle(color: Color(0xFFFCFCFC)),
                ),
                TextSpan(
                  text: 'US',
                  style: TextStyle(color: Color(0xFF1A46C2)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your business shouldn\'t have to wait '
            'for a cash shortage to happen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFCFCFC),
              fontSize: 28,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // ==================================================
          // WHY US CARDS
          // ==================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: WhyUsCard(
                  path: 'assets/icons/predict.svg',
                  title: 'Predict',
                  desc:
                      'Identify potential cash shortages '
                      'early with clear explanations.',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: WhyUsCard(
                  path: 'assets/icons/simulate.svg',
                  title: 'Simulation',
                  desc:
                      'Test different scenarios and '
                      'understand their possible impact.',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: WhyUsCard(
                  path: 'assets/icons/solution.svg',
                  title: 'Solutions',
                  desc:
                      'Receive AI-powered recommendations '
                      'tailored to your situation.',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: WhyUsCard(
                  path: 'assets/icons/syn.svg',
                  title: 'Sync',
                  desc:
                      'Keep forecasts aligned with your '
                      'latest financial data.',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: WhyUsCard(
                  path: 'assets/icons/Users.svg',
                  title: 'Permission',
                  desc:
                      'Securely give the right people '
                      'access to your workspace.',
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
// WHY US CARD
// ============================================================

class WhyUsCard extends StatefulWidget {
  final String path;
  final String title;
  final String desc;

  const WhyUsCard({
    super.key,
    required this.path,
    required this.title,
    required this.desc,
  });

  @override
  State<WhyUsCard> createState() => _WhyUsCardState();
}

class _WhyUsCardState extends State<WhyUsCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2348AF), Color(0xFF0E1449)],
            stops: [0.0, 1.0],
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF2348AF).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              widget.path,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFFCFCFC),
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.desc,
              style: const TextStyle(
                color: Color(0xFFFCFCFC),
                fontSize: 12,
                height: 1.35,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
