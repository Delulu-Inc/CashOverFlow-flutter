import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/responsive.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  static const List<String> _features = [
    'Cash-flow forecasting',
    'Risk detection with explanations',
    'AI-powered recommendations',
    'What-if simulations',
    'Role-based permissions',
  ];

  /// Tablets & phones: plan details above the chart.
  Widget _buildCompact(BuildContext context) {
    final double width = context.screenWidth;
    final bool isMobile = width < Breakpoints.mobile;
    final double gutter = Responsive.landingGutter(width);

    return Container(
      width: double.infinity,
      color: const Color(0xFF050505),
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: isMobile ? 56 : 72,
      ),
      child: Column(
        children: [
          Text(
            'Pricing',
            style: TextStyle(
              fontFamily: 'inter',
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A46C2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Powerful cash-flow intelligence',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'inter',
              fontSize: isMobile ? 30 : 38,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFCFCFC),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 655),
            child: Text(
              'One flexible plan with everything your business needs to predict risks, understand your cash position, and make smarter decisions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'inter',
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE6E6E6),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 40 : 56),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1036),
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFCFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash Flow AI',
                  style: TextStyle(
                    fontFamily: 'inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF050505),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Build Better Visibility',
                  style: TextStyle(
                    fontFamily: 'inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF050505),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Everything you need to predict, understand, and stay ahead of your cash.',
                  style: TextStyle(
                    fontFamily: 'inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: '\$${AppConfig.planPricePerYear} ',
                        style: TextStyle(
                          fontSize: 28,
                          color: Color(0xFF050505),
                        ),
                      ),
                      TextSpan(
                        text: '/year',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < _features.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check, color: Color(0xFF050505)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _features[i],
                          style: const TextStyle(
                            fontFamily: 'inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF050505),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: isMobile ? double.infinity : 320,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.register),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A46C2),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFCFCFC),
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const ForecastChart(),
              ],
            ),
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

    // Desktop: original Figma layout (full-bleed background, 1440px frame).
    return Container(
      width: double.infinity,
      height: 909,
      color: Color(0xFF050505),
      padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 80),
      child: Center(
        child: Column(
          children: [
            Text(
              "Pricing",
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A46C2),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Powerful cash-flow intelligence",
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 48,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFCFCFC),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 655,
              //height: 60,
              child: Text(
                "One flexible plan with everything your business needs to predict risks, understand your cash position, and make smarter decisions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "inter",
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFE6E6E6),
                ),
              ),
            ),
            SizedBox(height: 80),
            Container(
              width: 1036,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cash Flow AI",
                        style: TextStyle(
                          fontFamily: "inter",
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF050505),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Build Better Visibility",
                        style: TextStyle(
                          fontFamily: "inter",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF050505),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Everything you need to predict, understand, and stay\n ahead of your cash.",
                        style: TextStyle(
                          fontFamily: "inter",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 16),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: '\$${AppConfig.planPricePerYear} ',
                              style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFF050505),
                              ),
                            ),
                            TextSpan(
                              text: '/year',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF808080),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check, color: Color(0xFF050505)),
                              SizedBox(width: 8),
                              Text(
                                "Cash-flow forecasting",
                                style: TextStyle(
                                  fontFamily: "inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF050505),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check, color: Color(0xFF050505)),
                              SizedBox(width: 8),
                              Text(
                                "Risk detection with explanations",
                                style: TextStyle(
                                  fontFamily: "inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF050505),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check, color: Color(0xFF050505)),
                              SizedBox(width: 8),
                              Text(
                                "AI-powered recommendations",
                                style: TextStyle(
                                  fontFamily: "inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF050505),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check, color: Color(0xFF050505)),
                              SizedBox(width: 8),
                              Text(
                                "What-if simulations",
                                style: TextStyle(
                                  fontFamily: "inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF050505),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check, color: Color(0xFF050505)),
                              SizedBox(width: 8),
                              Text(
                                "Role-based permissions",
                                style: TextStyle(
                                  fontFamily: "inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF050505),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: 320,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.register);
                              },
                              style: ElevatedButton.styleFrom(
                                //minimumSize: Size(101, 27),
                                backgroundColor: const Color(0xFF1A46C2),
                                padding: EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1000),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFCFCFC),
                                  fontFamily: "inter",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 60),
                  Expanded(flex: 6, child: ForecastChart()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForecastChart extends StatelessWidget {
  const ForecastChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 1160.0;
        final chartHeight = width * (330 / 1160);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: chartHeight,
              child: CustomPaint(
                painter: ForecastChartPainter(),
                size: Size(width, chartHeight),
              ),
            ),
            SizedBox(height: width * 0.024),
            Text(
              "Turn your financial data into a clearer picture of what's coming next.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (width * 0.0225).clamp(14.0, 26.0),
                color: const Color(0xFF9297A3),
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ForecastChartPainter extends CustomPainter {
  // Key waypoints as fractions of the canvas (dx: left→right, dy: top→bottom).
  // Index 4 is the "today" point where actuals become forecast.
  static const List<Offset> _points = [
    Offset(0.00, 0.52),
    Offset(0.15, 0.62),
    Offset(0.30, 0.18),
    Offset(0.44, 0.62),
    Offset(0.645, 0.10), // <- transition / marker point
    Offset(0.80, 0.24),
    Offset(0.90, 0.03),
    Offset(1.00, 0.13),
  ];

  static const int _transitionIndex = 4;

  static const Color _blue = Color(0xFF3A5CE0);
  static const Color _markerFill = Color(0xFF4B4FDE);
  static const Color _triangleColor = Color(0xFF0A0E2C);
  static const Color _dashGray = Color(0xFFAFB3C2);
  static const Color _dividerGray = Color(0xFFDCDEE6);
  static const Color _forecastFill = Color(0xFFB9BEDD);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = _points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final solidPts = pts.sublist(0, _transitionIndex + 1);
    final dashedPts = pts.sublist(_transitionIndex);

    final solidPath = _smoothPath(solidPts);
    final dashedPath = _smoothPath(dashedPts);
    final transitionPoint = pts[_transitionIndex];

    // ---------- Fill under the solid (actual) portion ----------
    final solidFill = Path.from(solidPath)
      ..lineTo(transitionPoint.dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      solidFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_blue.withValues(alpha: .30), _blue.withValues(alpha: .0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // ---------- Fill under the dashed (forecast) portion ----------
    final dashedFill = Path.from(dashedPath)
      ..lineTo(size.width, size.height)
      ..lineTo(transitionPoint.dx, size.height)
      ..close();
    canvas.drawPath(
      dashedFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _forecastFill.withValues(alpha: .32),
            _forecastFill.withValues(alpha: .0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // ---------- Vertical divider under the marker ----------
    canvas.drawLine(
      transitionPoint,
      Offset(transitionPoint.dx, size.height),
      Paint()
        ..color = _dividerGray
        ..strokeWidth = 1.5,
    );

    // ---------- Solid blue line ----------
    canvas.drawPath(
      solidPath,
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ---------- Dashed gray line ----------
    _drawDashedPath(
      canvas,
      dashedPath,
      Paint()
        ..color = _dashGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
      dashWidth: size.width * 0.006,
      dashGap: size.width * 0.006,
    );

    // ---------- Marker: circle ----------
    final circleRadius = size.width * 0.0115;
    canvas.drawCircle(
      transitionPoint,
      circleRadius,
      Paint()..color = _markerFill,
    );

    // ---------- Marker: triangle pointing down, sitting above the circle ----------
    final triW = size.width * 0.016;
    final triH = size.width * 0.020;
    final triBottom = Offset(
      transitionPoint.dx,
      transitionPoint.dy - circleRadius * 2.1,
    );
    final trianglePath = Path()
      ..moveTo(triBottom.dx - triW, triBottom.dy - triH)
      ..lineTo(triBottom.dx + triW, triBottom.dy - triH)
      ..lineTo(triBottom.dx, triBottom.dy)
      ..close();
    canvas.drawPath(trianglePath, Paint()..color = _triangleColor);
  }

  /// Builds a smooth curve through [pts] using a Catmull-Rom → cubic Bézier
  /// conversion, so the line flows naturally through every waypoint.
  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length < 3) {
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      return path;
    }
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = (i + 2 < pts.length) ? pts[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashWidth,
    required double dashGap,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ForecastChartPainter oldDelegate) => false;
}
