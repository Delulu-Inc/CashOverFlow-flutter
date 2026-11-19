import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(loadProductionFonts);

  testWidgets('unknown URLs open the landing page', (tester) async {
    await pumpCashOverflowApp(tester, route: '/does-not-exist');
    expect(find.text('Predict, Prevent, Plan ahead.'), findsOneWidget);
  });

  testWidgets('login stores the session and opens the dashboard', (
    tester,
  ) async {
    await pumpCashOverflowApp(tester, route: '/login', signedIn: false);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'sarah@company.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Secret#123');
    await tester.tap(find.text('Log In'));
    await settle(tester);

    expect(find.text('Cash Flow Analysis'), findsOneWidget);
    expect(find.text('Sarah'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), 'test-token');
    expect(prefs.getString('user_email'), 'sarah@company.com');
  });

  testWidgets('login accepts e-mails with + and - characters', (tester) async {
    await pumpCashOverflowApp(tester, route: '/login', signedIn: false);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'sarah+finance@my-company.co',
    );
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsNothing);
  });

  testWidgets('owners see the owner-only sidebar entries', (tester) async {
    await pumpCashOverflowApp(tester, route: '/team-management');

    expect(find.text('Accounts with access'), findsOneWidget);
    expect(find.text('Michael Anderson'), findsOneWidget);
    expect(find.text('Subscription'), findsOneWidget);
  });

  testWidgets('non-owners are redirected away from owner-only pages', (
    tester,
  ) async {
    await pumpCashOverflowApp(
      tester,
      route: '/team-management',
      role: 'FinanceManager',
    );

    expect(find.text('Accounts with access'), findsNothing);
    expect(find.text('Cash Flow Analysis'), findsOneWidget);
    expect(find.text('Team Management'), findsNothing);
  });

  testWidgets('switching the forecast period reloads the dashboard', (
    tester,
  ) async {
    final backend = await pumpCashOverflowApp(tester, route: '/dashboard');

    await tester.tap(find.text('Next 90 Days'));
    await settle(tester);

    expect(find.text('Cash over the next 90 days'), findsOneWidget);
    expect(
      backend.requests.any(
        (r) =>
            r.url.path.endsWith('/forecast') &&
            r.url.queryParameters['horizonDays'] == '90',
      ),
      isTrue,
    );
  });

  testWidgets('touching the fan chart shows a tooltip without errors', (
    tester,
  ) async {
    await pumpCashOverflowApp(tester, route: '/dashboard');

    final chart = find.byType(LineChart);
    expect(chart, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(chart));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    await gesture.up();
    await settle(tester);
  });

  testWidgets('register form validates required fields', (tester) async {
    await pumpCashOverflowApp(tester, route: '/register', signedIn: false);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Please enter your first name'), findsOneWidget);
    expect(find.text('Please enter your company email'), findsOneWidget);
  });

  testWidgets('admin dashboard requires a session', (tester) async {
    await pumpCashOverflowApp(
      tester,
      route: '/admin-dashboard',
      signedIn: false,
    );

    expect(find.text('Welcome back!'), findsOneWidget);
  });

  testWidgets('admin dashboard lists and normalizes demo requests', (
    tester,
  ) async {
    await pumpCashOverflowApp(tester, route: '/admin-dashboard');

    expect(find.text('Acme Retail'), findsOneWidget);
    // "pending" from the API is displayed as "Pending" with its action.
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approve & Send Email'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'nile');
    await tester.pump();
    expect(find.text('Acme Retail'), findsNothing);
    expect(find.text('Nile Logistics'), findsOneWidget);
  });

  testWidgets('logging out invalidates the server session and clears it', (
    tester,
  ) async {
    final backend = await pumpCashOverflowApp(tester, route: '/dashboard');

    await tester.tap(find.text('Log out'));
    await settle(tester);

    expect(find.text('Welcome back!'), findsOneWidget);
    final logout = backend.requests.singleWhere(
      (r) => r.method == 'POST' && r.url.path.endsWith('/logout'),
    );
    expect(logout.headers['Authorization'], 'Bearer test-token');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
  });

  testWidgets('owners can remove a member after confirming', (tester) async {
    final backend = await pumpCashOverflowApp(
      tester,
      route: '/team-management',
    );

    final removeButtons = find.widgetWithText(OutlinedButton, 'Remove access');
    expect(removeButtons, findsNWidgets(2));

    // Row 1 is the signed-in owner: removing yourself is disabled.
    expect(tester.widget<OutlinedButton>(removeButtons.at(0)).enabled, isFalse);

    await tester.tap(removeButtons.at(1));
    await settle(tester);
    expect(find.text('Remove access?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
    await settle(tester);

    expect(
      backend.requests.any(
        (r) => r.method == 'DELETE' && r.url.path.endsWith('/team/member/2'),
      ),
      isTrue,
    );
    expect(find.text('Access removed for Michael Anderson.'), findsOneWidget);
  });

  testWidgets('activate plan charges the advertised yearly price', (
    tester,
  ) async {
    final backend = await pumpCashOverflowApp(
      tester,
      route: '/accept-invite?token=invite-123',
      signedIn: false,
    );

    expect(find.text('\$499'), findsOneWidget);

    await tester.tap(find.text('Proceed to Secure Payment'));
    await settle(tester);

    final checkout = backend.requests.singleWhere(
      (r) => r.url.path.endsWith('/Checkout/create-session'),
    );
    final body = jsonDecode(checkout.body) as Map<String, dynamic>;
    expect(body['amount'], 499);
    expect(body['planName'], 'Pro');
    expect(body['invitationToken'], 'invite-123');
  });

  testWidgets('payment success forwards the invitation token', (tester) async {
    final backend = await pumpCashOverflowApp(
      tester,
      route: '/payment-success?session_id=cs_test&token=invite-123&orgId=org-9',
      signedIn: false,
    );

    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.text('Set your password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Secret#123');
    await tester.enterText(find.byType(TextFormField).at(1), 'Secret#123');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set Password'));
    await settle(tester);

    final accept = backend.requests.singleWhere(
      (r) => r.url.path.endsWith('/onboarding/accept-invite'),
    );
    expect(accept.body, contains('"token":"invite-123"'));
    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
