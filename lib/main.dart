import 'dart:html' as html;
// import 'package:cash_overflow/Activate_plan_page.dart';
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
        final String rawRouteName = settings.name ?? '/';
        
        // استخراج الـ Path النظيف بدون query parameters
        final Uri routeUri = Uri.parse(rawRouteName);
        final String path = routeUri.path;

        // دالة مساعدة لقراءة الـ URI من الـ Hash أو الـ URL المباشر
        Uri getFullUri() {
          return Uri.parse(
            html.window.location.hash.isNotEmpty
                ? html.window.location.hash.substring(1)
                : html.window.location.href,
          );
        }

        // 1. مسار قبول الدعوة
        if (path.startsWith('/accept-invite')) {
          final uri = getFullUri();
          final String? inviteToken = uri.queryParameters['token'];

          return MaterialPageRoute(
            builder: (context) => ActivatePlan(inviteToken: inviteToken),
          );
        }

        // 2. مسار ضبط كلمة السر
        if (path.startsWith('/set-password')) {
          final uri = getFullUri();
          final String? inviteToken = uri.queryParameters['token'];
          final String? orgId = uri.queryParameters['orgId'];

          return MaterialPageRoute(
            builder: (context) => SetPasswordPage(token: inviteToken, orgId: orgId),
          );
        }

        // 3. مسار نجاح الدفع (تعديل المقارنة للتعامل مع الـ query parameters)
        if (path.startsWith('/payment-success')) {
          final uri = getFullUri();
          final String? sessionId = uri.queryParameters['session_id'];

          return MaterialPageRoute(
            builder: (context) => DoneAfterSubscripePage(sessionId: sessionId),
          );
        }

        // 4. مسار فشل الدفع
        if (path.startsWith('/payment-failed') || path.startsWith('/payment-cancel')) {
          final uri = getFullUri();
          final String? errorMessage = uri.queryParameters['error'];

          return MaterialPageRoute(
            builder: (context) => PaymentFailedPage(errorMessage: errorMessage),
          );
        }

        // 5. مسار تسجيل الدخول
        if (path == '/login') {
          return MaterialPageRoute(builder: (context) => const SignInPage());
        }

        // Default: Landing Page
        return MaterialPageRoute(builder: (context) => const LandingPage());
      },
      debugShowCheckedModeBanner: false,
      title: 'Cash Overflow',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
    );
  }
}