import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/about_us_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/features_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/landing_nav_drawer.dart';
import '../widgets/pricing_section.dart';
import '../widgets/problem_solution_section.dart';
import '../widgets/reviews_section.dart';

/// Public marketing page.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the above-the-fold image early so the hero never pops in.
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      precacheImage(
        const AssetImage('assets/images/cashflow_hero.jpg'),
        context,
      );
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.landingBackground,
      // Desktop shows the inline navigation bar of the hero instead.
      endDrawer: context.screenWidth < Breakpoints.desktop
          ? LandingNavDrawer(
              onAboutTap: () => _scrollToSection(_aboutKey),
              onFeaturesTap: () => _scrollToSection(_featuresKey),
              onFooterTap: () => _scrollToSection(_footerKey),
              onPricingTap: () => _scrollToSection(_pricingKey),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(
              onAboutTap: () => _scrollToSection(_aboutKey),
              onFeaturesTap: () => _scrollToSection(_featuresKey),
              onFooterTap: () => _scrollToSection(_footerKey),
              onPricingTap: () => _scrollToSection(_pricingKey),
              onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            ProblemSolutionSection(scrollController: _scrollController),
            FeaturesSection(key: _featuresKey),
            AboutUsSection(key: _aboutKey),
            const CtaSection(),
            const ReviewsSection(),
            PricingSection(key: _pricingKey),
            FooterSection(key: _footerKey),
          ],
        ),
      ),
    );
  }
}
