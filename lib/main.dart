import 'dart:html' as html;
//import 'package:cash_overflow/Activate_plan_page.dart'; 
import 'package:cash_overflow/Done_after_subscripe_page.dart';
import 'package:cash_overflow/SignIn_page.dart';
import 'package:cash_overflow/failed_payment.dart';
import 'package:cash_overflow/landing_page.dart';
import 'package:cash_overflow/plansubscribtion.dart';
import 'package:cash_overflow/set_password_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final String currentUrl = html.window.location.href;
        final Uri uri = Uri.parse(
          currentUrl.contains('#')
              ? currentUrl.split('#').last
              : settings.name ?? '/',
        );

        if (uri.path == '/accept-invite') {
          final String? inviteToken = uri.queryParameters['token'];
          return MaterialPageRoute(
            builder: (context) => ActivatePlan(inviteToken: inviteToken),
          );
        }

        if (uri.path == '/set-password') {
          final String? inviteToken = uri.queryParameters['token'];
          final String? orgId = uri.queryParameters['orgId'];

          return MaterialPageRoute(
            builder: (context) =>
                SetPasswordPage(token: inviteToken, orgId: orgId),
          );
        }

        if (uri.path == '/payment-success') {
          final String? sessionId = uri.queryParameters['session_id'];
          return MaterialPageRoute(
            builder: (context) => DoneAfterSubscripePage(sessionId: sessionId),
          );
        }

        if (uri.path == '/payment-failed' || uri.path == '/payment-cancel') {
          final String? errorMessage = uri.queryParameters['error'];
          return MaterialPageRoute(
            builder: (context) => PaymentFailedPage(errorMessage: errorMessage),
          );
        }

        if (uri.path == '/login') {
          return MaterialPageRoute(
            builder: (context) => const SignInPage(),
          );
        }

        // Default Route
        return MaterialPageRoute(builder: (context) => const LandingPage());
      },
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Shell',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
    );
  }
}