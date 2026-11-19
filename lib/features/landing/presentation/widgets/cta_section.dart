import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/responsive.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  static const LinearGradient _background = LinearGradient(
    colors: [
      Color(0xFF000F16),
      Color(0xFF000D13),
      Color(0xFF010A0F),
      Color(0xFF01060A),
      Color(0xFF000000),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Tablets & phones: text, button and image stacked.
  Widget _buildCompact(BuildContext context) {
    final double width = context.screenWidth;
    final bool isMobile = width < Breakpoints.mobile;
    final double gutter = Responsive.landingGutter(width);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: isMobile ? 56 : 72,
      ),
      decoration: const BoxDecoration(gradient: _background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Give your business back the clarity cash flow uncertainty was taking away.',
            style: TextStyle(
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFCFCFC),
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: isMobile ? 32 : 40),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.register),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 24,
                vertical: isMobile ? 16 : 20,
              ),
              side: const BorderSide(color: Color(0xFFFCFCFC), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1000),
              ),
              foregroundColor: const Color(0xFFFCFCFC),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start Demo',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: const Color(0xFFFCFCFC),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.north_east,
                  size: isMobile ? 20 : 24,
                  color: const Color(0xFFFCFCFC),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 40 : 56),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 444),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  'assets/images/CTA.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF11141A),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.white24,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
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

    // Desktop: original Figma layout.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(96, 80, 0, 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF000F16),
            Color(0xFF000D13),
            Color(0xFF010A0F),
            Color(0xFF01060A),
            Color(0xFF000000),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Give your business back the\n'
                  'clarity cash flow uncertainty was\n'
                  'taking away.',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFFCFCFC),
                    height: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 48),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.register);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    side: const BorderSide(color: Color(0xFFFCFCFC), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    foregroundColor: const Color(0xFFFCFCFC),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Demo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFCFCFC),
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.north_east,
                        size: 24,
                        color: Color(0xFFFCFCFC),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Image.asset(
              'assets/images/CTA.jpg',
              width: 444,
              height: 444,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 444,
                  height: 444,
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
        ],
      ),
    );
  }
}
