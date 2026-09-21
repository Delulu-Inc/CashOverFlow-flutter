import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'package:cash_overflow/Dashboard_page.dart';
import 'package:cash_overflow/ai_support.dart';
import 'package:cash_overflow/TeamManagementPage.dart';
import 'package:cash_overflow/subscribe/subscription_screen.dart';
import 'package:cash_overflow/Profile_settings_page.dart';
import 'package:cash_overflow/widgets/Sidebar.dart';

class DashboardShell extends StatefulWidget {
  final String initialRoute;

  const DashboardShell({super.key, required this.initialRoute});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  late String _currentRoute;

  @override
  void initState() {
    super.initState();

    _currentRoute = _normalizeRoute(widget.initialRoute);
  }

  String _normalizeRoute(String route) {
    if (route.isEmpty) {
      return '/dashboard';
    }

    if (!route.startsWith('/')) {
      return '/$route';
    }

    return route;
  }

  void _changePage(String route) {
    final normalizedRoute = _normalizeRoute(route);

    debugPrint('SIDEBAR CLICKED: $normalizedRoute');

    if (_currentRoute == normalizedRoute) {
      return;
    }

    // Change the content immediately
    setState(() {
      _currentRoute = normalizedRoute;
    });

    // Change browser URL
    html.window.history.pushState(null, '', '#$normalizedRoute');

    debugPrint('CURRENT ROUTE: $_currentRoute');
    debugPrint('CURRENT URL: ${html.window.location.href}');
  }

  Widget _getCurrentPage() {
    switch (_currentRoute) {
      case '/dashboard':
        return DashboardPage(
          onOpenAiSupport: () {
            _changePage('/ai-support');
          },
        );

      case '/ai-support':
        return const ChatScreen();

      case '/team-management':
        return const TeamManagementPage();

      case '/subscription':
        return const SubscriptionBillingScreen();

      case '/profile-settings':
        return const ProfileSettingsPage();

      default:
        return const DashboardPage();
    }
  }

  String _getCurrentItemName() {
    switch (_currentRoute) {
      case '/dashboard':
        return 'Dashboard';

      case '/ai-support':
        return 'AI Support';

      case '/team-management':
        return 'Team Management';

      case '/subscription':
        return 'Subscription';

      case '/profile-settings':
        return 'Profile Settings';

      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // FIXED SIDEBAR
          SizedBox(
            width: 260,
            child: SidebarWidget(
              currentRoute: _getCurrentItemName(),

              onNavigate: (route) {
                debugPrint('onNavigate received: $route');
                _changePage(route);
              },
            ),
          ),

          // ONLY THIS PART CHANGES
          Expanded(child: _getCurrentPage()),
        ],
      ),
    );
  }
}
