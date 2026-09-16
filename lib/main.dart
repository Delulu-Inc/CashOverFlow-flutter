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
          return MaterialPageRoute(
            builder: (context) => ActivatePlan(),
          );
        }

        if (uri.path == '/payment-success') {
          return MaterialPageRoute(builder: (context) => const DoneAfterSubscripePage());
        }

        if (uri.path == '/payment-failed') {
          return MaterialPageRoute(builder: (context) => const PaymentFailedPage());
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