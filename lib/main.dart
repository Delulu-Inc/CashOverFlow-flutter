import 'package:flutter/material.dart';

import 'package:cash_overflow/Done_after_subscripe_page.dart';
import 'package:cash_overflow/SignIn_page.dart';
import 'package:cash_overflow/failed_payment.dart';
import 'package:cash_overflow/landing_page.dart';
import 'package:cash_overflow/plansubscribtion.dart';
import 'package:cash_overflow/set_password_page.dart';
import 'package:cash_overflow/dashboard_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ============================================================
  // GET CURRENT URL
  // ============================================================
  //
  // Supports:
  //
  // https://site.com/#/dashboard
  //
  // and:
  //
  // https://site.com/dashboard
  //
  Uri _getCurrentUri() {
    final Uri baseUri = Uri.base;

    // ----------------------------------------------------------
    // Hash URL
    // ----------------------------------------------------------
    if (baseUri.fragment.isNotEmpty) {
      String fragment = baseUri.fragment;

      if (!fragment.startsWith('/')) {
        fragment = '/$fragment';
      }

      return Uri.parse(fragment);
    }

    // ----------------------------------------------------------
    // Normal URL
    // ----------------------------------------------------------
    return baseUri;
  }

  // ============================================================
  // CLEAN GITHUB PAGES REPOSITORY PATH
  // ============================================================
  String _cleanPath(String path) {
    const String repoName = '/CashOverFlow-flutter';

    if (path.startsWith(repoName)) {
      path = path.substring(repoName.length);
    }

    if (path.isEmpty) {
      return '/';
    }

    if (!path.startsWith('/')) {
      path = '/$path';
    }

    return path;
  }

  // ============================================================
  // CREATE PAGE ROUTE
  // ============================================================
  MaterialPageRoute _page(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cash Overflow',

      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),

      // ========================================================
      // ROUTING
      // ========================================================
      onGenerateRoute: (settings) {
        // ------------------------------------------------------
        // IMPORTANT
        //
        // For direct opening / refresh:
        //     Uri.base
        //
        // For normal Flutter navigation:
        //     settings.name
        //
        // Our Sidebar does NOT use Navigator for the internal
        // pages. DashboardShell handles those internally.
        // ------------------------------------------------------

        final Uri uri;

        if (settings.name != null &&
            settings.name!.isNotEmpty &&
            settings.name != '/') {
          uri = Uri.parse(settings.name!);
        } else {
          uri = _getCurrentUri();
        }

        final String path = _cleanPath(uri.path);

        final Map<String, String> queryParameters =
            uri.queryParameters;

        debugPrint('========================================');
        debugPrint('Browser URL: ${Uri.base}');
        debugPrint('Route name: ${settings.name}');
        debugPrint('Current Path: $path');
        debugPrint('Query Parameters: $queryParameters');
        debugPrint('========================================');

        // ======================================================
        // 1. LANDING PAGE
        // ======================================================
        if (path == '/') {
          return _page(
            settings,
            const LandingPage(),
          );
        }

        // ======================================================
        // 2. LOGIN
        // ======================================================
        if (path == '/login') {
          return _page(
            settings,
            const SignInPage(),
          );
        }

        // ======================================================
        // 3. DASHBOARD
        // ======================================================
        if (path == '/dashboard') {
          return _page(
            settings,
            const DashboardShell(
              initialRoute: '/dashboard',
            ),
          );
        }

        // ======================================================
        // 4. AI SUPPORT
        // ======================================================
        if (path == '/ai-support') {
          return _page(
            settings,
            const DashboardShell(
              initialRoute: '/ai-support',
            ),
          );
        }

        // ======================================================
        // 5. TEAM MANAGEMENT
        // ======================================================
        if (path == '/team-management') {
          return _page(
            settings,
            const DashboardShell(
              initialRoute: '/team-management',
            ),
          );
        }

        // ======================================================
        // 6. SUBSCRIPTION
        // ======================================================
        if (path == '/subscription') {
          return _page(
            settings,
            const DashboardShell(
              initialRoute: '/subscription',
            ),
          );
        }

        // ======================================================
        // 7. PROFILE SETTINGS
        // ======================================================
        if (path == '/profile-settings') {
          return _page(
            settings,
            const DashboardShell(
              initialRoute: '/profile-settings',
            ),
          );
        }

        // ======================================================
        // 8. ACCEPT INVITE
        // ======================================================
        if (path == '/accept-invite') {
          final String? token =
              queryParameters['token']?.trim();

          return _page(
            settings,
            ActivatePlan(
              inviteToken: token,
            ),
          );
        }

        // ======================================================
        // 9. SET PASSWORD
        // ======================================================
        if (path == '/set-password') {
          final String? token =
              queryParameters['token']?.trim();

          final String? orgId =
              queryParameters['orgId']?.trim();

          return _page(
            settings,
            SetPasswordPage(
              token: token,
              orgId: orgId,
            ),
          );
        }

        // ======================================================
        // 10. PAYMENT SUCCESS
        // ======================================================
        if (path == '/payment-success') {
          final String? sessionId =
              queryParameters['session_id']?.trim();

          return _page(
            settings,
            DoneAfterSubscripePage(
              sessionId: sessionId,
            ),
          );
        }

        // ======================================================
        // 11. PAYMENT FAILED
        // ======================================================
        if (path == '/payment-failed' ||
            path == '/payment-cancel') {
          final String? errorMessage =
              queryParameters['error']?.trim();

          return _page(
            settings,
            PaymentFailedPage(
              errorMessage: errorMessage,
            ),
          );
        }

        // ======================================================
        // UNKNOWN ROUTE
        // ======================================================
        return _page(
          settings,
          const LandingPage(),
        );
      },
    );
  }
}