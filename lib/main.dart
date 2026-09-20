import 'package:flutter/material.dart';
import 'package:cash_overflow/Done_after_subscripe_page.dart';
import 'package:cash_overflow/SignIn_page.dart';
import 'package:cash_overflow/failed_payment.dart';
import 'package:cash_overflow/landing_page.dart';
import 'package:cash_overflow/plansubscribtion.dart';
import 'package:cash_overflow/set_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// دالة مساعدة معالجة لاستخراج الـ URI والـ Query Parameters
  /// تضمن التعامل الصحيح مع الـ Hash Routing ومسارات GitHub Pages
  Uri _getCleanUri(RouteSettings settings) {
    final baseUri = Uri.base;

    // 1. إذا كان التطبيق يعتمد على Hash Strategy (/#/set-password)
    if (baseUri.hasFragment && baseUri.fragment.isNotEmpty) {
      final fragment = baseUri.fragment;
      final formattedFragment =
          fragment.startsWith('/') ? fragment : '/$fragment';
      return Uri.parse(formattedFragment);
    }

    // 2. إذا تم التوجيه عبر Navigator.pushNamed من داخل التطبيق
    if (settings.name != null && settings.name != '/') {
      return Uri.parse(settings.name!);
    }

    return baseUri;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final Uri fullUri = _getCleanUri(settings);

        // استخراج المسار الأساسي (Path) تنظيفه من أي بادئة خاصة بـ Base HREF
        String path = fullUri.path;
        if (path.contains('/CashOverFlow-flutter')) {
          path = path.replaceAll('/CashOverFlow-flutter', '');
        }
        if (path.isEmpty) {
          path = '/';
        }

        // 1. مسار قبول الدعوة (Activate Plan)
        if (path.startsWith('/accept-invite')) {
          final String? inviteToken = fullUri.queryParameters['token']?.trim();

          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ActivatePlan(inviteToken: inviteToken),
          );
        }

        // 2. مسار ضبط كلمة السر (Set Password)
        if (path.startsWith('/set-password')) {
          final String? inviteToken = fullUri.queryParameters['token']?.trim();
          final String? orgId = fullUri.queryParameters['orgId']?.trim();

          return MaterialPageRoute(
            settings: settings,
            builder: (context) =>
                SetPasswordPage(token: inviteToken, orgId: orgId),
          );
        }

        // 3. مسار نجاح الدفع
        if (path.startsWith('/payment-success')) {
          final String? sessionId =
              fullUri.queryParameters['session_id']?.trim();

          return MaterialPageRoute(
            settings: settings,
            builder: (context) =>
                DoneAfterSubscripePage(sessionId: sessionId),
          );
        }

        // 4. مسار فشل الدفع
        if (path.startsWith('/payment-failed') ||
            path.startsWith('/payment-cancel')) {
          final String? errorMessage = fullUri.queryParameters['error']?.trim();

          return MaterialPageRoute(
            settings: settings,
            builder: (context) =>
                PaymentFailedPage(errorMessage: errorMessage),
          );
        }

        // 5. مسار تسجيل الدخول
        if (path == '/login') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => const SignInPage(),
          );
        }

        // Default: Landing Page
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LandingPage(),
        );
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