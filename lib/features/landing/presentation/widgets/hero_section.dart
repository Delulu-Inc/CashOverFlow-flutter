import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onFeaturesTap;
  final VoidCallback onFooterTap;
  final VoidCallback onPricingTap;

  /// Opens the navigation drawer on tablets and phones.
  final VoidCallback? onMenuTap;

  const HeroSection({
    super.key,
    required this.onAboutTap,
    required this.onFeaturesTap,
    required this.onFooterTap,
    required this.onPricingTap,
    this.onMenuTap,
  });

  static const String _title = 'Predict, Prevent, Plan ahead.';
  static const String _subtitle =
      'AI helps you see financial problems before they happen, understand what\'s causing them, explore the best solutions, and simulate different outcomes so you can make smarter decisions with confidence.';

  void _openRegister(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.register);

  void _openLogin(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.login);

  /// Tablets & phones: compact navigation bar + stacked content.
  Widget _buildCompact(BuildContext context) {
    final double width = context.screenWidth;
    final bool isMobile = width < Breakpoints.mobile;
    final double gutter = Responsive.landingGutter(width);

    final ButtonStyle filledStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandBlue,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
    );
    final ButtonStyle outlinedStyle = OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      side: const BorderSide(color: AppColors.offWhite),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
    );
    final TextStyle buttonTextStyle = TextStyle(
      fontSize: isMobile ? 16 : 18,
      color: AppColors.offWhite,
      height: 1.5,
      fontWeight: FontWeight.w600,
      fontFamily: 'inter',
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isMobile ? 640 : 760,
        minWidth: double.infinity,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cashflow_hero.jpg',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Color(0xE6000000),
                    Color(0x99000000),
                    Color(0x80000000),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 20, gutter - 8, 0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CashFlow',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'inter',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: onMenuTap,
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 72 : 120),
              // Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: isMobile ? 36 : 48,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                        color: AppColors.offWhite,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 799),
                      child: Text(
                        _subtitle,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 20,
                          color: AppColors.offWhite,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'inter',
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 36 : 48),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ElevatedButton(
                          onPressed: () => _openRegister(context),
                          style: filledStyle,
                          child: Text('Start now', style: buttonTextStyle),
                        ),
                        OutlinedButton(
                          onPressed: () => _openRegister(context),
                          style: outlinedStyle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Try Demo', style: buttonTextStyle),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.north_east,
                                size: isMobile ? 20 : 24,
                                color: AppColors.offWhite,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 72 : 120),
            ],
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
    return SizedBox(
      height: 900,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/cashflow_hero.jpg', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black,
                  Color(0xE6000000), // ~90% black
                  Color(0x99000000), // ~60% black
                  Color(0x4D000000), // ~30% black
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
          Column(
            children: [
              // Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 96,
                  vertical: 32,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 18),
                    const Text(
                      'CashFlow',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: "inter",
                      ),
                    ),
                    const Spacer(),
                    _NavText('About', onTap: onAboutTap),
                    _NavText('Features', onTap: onFeaturesTap),
                    _NavText('Contact', onTap: onFooterTap),
                    _NavText('Pricing', onTap: onPricingTap),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _openRegister(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A46C2),
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                      child: const Text(
                        'Subscribe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: "inter",
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    OutlinedButton(
                      onPressed: () {
                        _openLogin(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCFCFC)),
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFCFCFC),
                          fontFamily: "inter",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 160),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Predict, Prevent, Plan ahead.',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w600,
                          fontFamily: "inter",
                          color: Color(0xFFFCFCFC),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 799,
                        child: Text(
                          'AI helps you see financial problems before they happen, understand what\'s causing them, explore the best solutions, and simulate different outcomes so you can make smarter decisions with confidence.',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFFFCFCFC),
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: "inter",
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _openRegister(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A46C2),
                              padding: const EdgeInsets.all(24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                            child: const Text(
                              'Start now',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFFCFCFC),
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: "inter",
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                          OutlinedButton(
                            onPressed: () {
                              _openRegister(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(24),
                              side: const BorderSide(color: Color(0xFFFCFCFC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Try Demo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFFCFCFC),
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "inter",
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 264),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavText extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavText(this.title, {required this.onTap});

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
