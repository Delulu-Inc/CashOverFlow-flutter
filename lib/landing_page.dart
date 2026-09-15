import 'package:flutter/material.dart';
import 'landing_widgets/about_us_section.dart';
import 'landing_widgets/cta_section.dart';
import 'landing_widgets/features_section.dart';
import 'landing_widgets/footer_section.dart';
import 'landing_widgets/hero_section.dart';
import 'landing_widgets/pricing_section.dart';
import 'landing_widgets/problems_solutions.dart';
import 'landing_widgets/reviews_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

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
      backgroundColor: const Color(0xFF07080C),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(
              onAboutTap: () => _scrollToSection(_aboutKey),
              onFeaturesTap: () => _scrollToSection(_featuresKey),
              onFooterTap: () => _scrollToSection(_footerKey),
              onPricingTap: () => _scrollToSection(_pricingKey),
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