import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

/// Every page is rendered at phone, tablet, laptop and desktop widths with
/// production fonts. Any RenderFlex overflow or layout exception fails the
/// test, which guarantees the app is responsive end to end.
const List<double> _widths = [360, 768, 1024, 1280, 1366, 1440, 1920];

const List<String> _routes = [
  '/',
  '/login',
  '/register',
  '/register/success',
  '/accept-invite?token=abc',
  '/set-password?token=abc',
  '/payment-success?session_id=cs_test',
  '/payment-failed',
  '/dashboard',
  '/ai-support',
  '/team-management',
  '/subscription',
  '/profile-settings',
  '/admin-dashboard',
];

final bool _sdkFontsAvailable = Directory(
  '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts',
).existsSync();

void main() {
  setUpAll(loadProductionFonts);

  for (final route in _routes) {
    group(route, () {
      for (final width in _widths) {
        testWidgets(
          'has no layout overflow at ${width.toInt()}px',
          (tester) async {
            await pumpCashOverflowApp(
              tester,
              route: route,
              size: Size(width, width < 600 ? 800 : 900),
            );
            expect(tester.takeException(), isNull);
          },
          skip: !_sdkFontsAvailable,
        );
      }
    });
  }

  group('navigation drawers on phones', () {
    testWidgets('landing menu opens the drawer', (tester) async {
      await pumpCashOverflowApp(tester, size: const Size(375, 812));

      await tester.tap(find.byTooltip('Menu'));
      await settle(tester);

      expect(find.text('Pricing'), findsWidgets);
      expect(find.text('Subscribe'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, skip: !_sdkFontsAvailable);

    testWidgets('dashboard menu opens the sidebar drawer', (tester) async {
      await pumpCashOverflowApp(
        tester,
        route: '/dashboard',
        size: const Size(375, 812),
      );

      await tester.tap(find.byTooltip('Menu'));
      await settle(tester);

      expect(find.text('Profile Settings'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, skip: !_sdkFontsAvailable);
  });
}
