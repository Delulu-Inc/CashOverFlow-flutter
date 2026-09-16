import 'package:cash_overflow/Activate_plan_page.dart';
import 'package:cash_overflow/Done_after_subscripe_page.dart';
import 'package:cash_overflow/SignIn_page.dart';
import 'package:cash_overflow/failed_payment.dart';
import 'package:cash_overflow/landing_page.dart';
import 'package:cash_overflow/plansubscribtion.dart';
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
        final Uri uri = Uri.parse(settings.name ?? '/');
        if (uri.path == '/accept-invite') {
          final String? inviteToken = uri.queryParameters['token'];

          return MaterialPageRoute(
            builder: (context) => ActivatePlan(inviteToken: inviteToken),
          );
        }

        if (uri.path == '/payment-success') {
          final String? sessionId = uri.queryParameters['session_id'];
          return MaterialPageRoute(
            builder: (context) => DoneAfterSubscripePage(sessionId: sessionId),
          );
        }

        if (uri.path == '/payment-cancel') {
          return MaterialPageRoute(
            builder: (context) => const PaymentFailedPage(),
          );
        }

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
