import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../features/admin/presentation/pages/demo_requests_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/widgets/require_session.dart';
import '../../features/checkout/presentation/pages/activate_plan_page.dart';
import '../../features/checkout/presentation/pages/payment_failed_page.dart';
import '../../features/checkout/presentation/pages/payment_success_page.dart';
import '../../features/dashboard/presentation/dashboard_section.dart';
import '../../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/onboarding/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/registration_success_page.dart';
import 'app_routes.dart';

/// Maps URLs to pages.
///
/// Supports hash URLs (`/#/dashboard`), path URLs (`/dashboard`, used by the
/// Vercel rewrites) and the GitHub Pages sub-path (`/CashOverFlow-flutter/`).
abstract final class AppRouter {
  /// Builds the first page from the URL the browser was opened with.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    final uri = (initialRoute.isEmpty || initialRoute == AppRoutes.landing)
        ? currentBrowserUri()
        : Uri.parse(initialRoute);
    final name = routeNameOf(uri);
    return [_buildRoute(Uri.parse(name), RouteSettings(name: name))];
  }

  /// Builds pages pushed with `Navigator.pushNamed`.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final uri = Uri.parse(
      (name == null || name.isEmpty) ? AppRoutes.landing : name,
    );
    return _buildRoute(uri, settings);
  }

  /// The URL the app was opened with, from the hash fragment when present.
  static Uri currentBrowserUri() {
    final base = Uri.base;
    if (base.fragment.isNotEmpty) {
      final fragment = base.fragment.startsWith('/')
          ? base.fragment
          : '/${base.fragment}';
      return Uri.parse(fragment);
    }
    return base;
  }

  /// Relative route name (`/path?query`) for [uri].
  static String routeNameOf(Uri uri) {
    final path = normalizePath(uri.path);
    return Uri(
      path: path,
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
  }

  /// Strips the GitHub Pages sub-path and trailing slashes.
  static String normalizePath(String path) {
    var result = path;
    if (result.startsWith(AppConfig.githubPagesBasePath)) {
      result = result.substring(AppConfig.githubPagesBasePath.length);
    }
    if (result.isEmpty) return AppRoutes.landing;
    if (!result.startsWith('/')) result = '/$result';
    while (result.length > 1 && result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  static Route<dynamic> _buildRoute(Uri uri, RouteSettings settings) {
    final path = normalizePath(uri.path);

    String? param(String key) {
      final value = uri.queryParameters[key]?.trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    switch (path) {
      case AppRoutes.landing:
        return _page(settings, const LandingPage());
      case AppRoutes.login:
        return _page(settings, const SignInPage(), title: 'Log In');
      case AppRoutes.register:
        return _page(settings, const RegisterPage(), title: 'Register');
      case AppRoutes.registrationSuccess:
        return _page(
          settings,
          const RegistrationSuccessPage(),
          title: 'Request received',
        );
      case AppRoutes.acceptInvite:
        return _page(
          settings,
          ActivatePlanPage(inviteToken: param('token')),
          title: 'Activate your plan',
        );
      case AppRoutes.setPassword:
        return _page(
          settings,
          SetPasswordPage(
            token: param('token'),
            orgId: param('orgId'),
            type: param('type'),
          ),
          title: 'Set your password',
        );
      case AppRoutes.paymentSuccess:
        return _page(
          settings,
          PaymentSuccessPage(
            sessionId: param('session_id'),
            token: param('token'),
            orgId: param('orgId'),
          ),
          title: 'Payment successful',
        );
      case AppRoutes.paymentFailed:
      case AppRoutes.paymentCancel:
        return _page(
          settings,
          PaymentFailedPage(errorMessage: param('error')),
          title: 'Payment unsuccessful',
        );
    }

    if (path.startsWith(AppRoutes.adminDashboard)) {
      return _page(
        settings,
        const RequireSession(
          backgroundColor: AppColors.dashboardBackground,
          child: DemoRequestsPage(),
        ),
        title: 'Demo Requests',
      );
    }

    final section = DashboardSection.fromRoute(path);
    if (section != null) {
      // The shell sets the browser tab title of each sidebar page itself.
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DashboardShell(initialSection: section),
      );
    }

    // Unknown URL → landing page.
    return _page(settings, const LandingPage());
  }

  static MaterialPageRoute<void> _page(
    RouteSettings settings,
    Widget page, {
    String? title,
  }) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Title(
        title: AppConfig.pageTitle(title),
        color: AppColors.brandBlue,
        child: page,
      ),
    );
  }
}
