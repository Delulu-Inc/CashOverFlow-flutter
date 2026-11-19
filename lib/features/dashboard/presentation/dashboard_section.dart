import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';

/// Pages reachable from the dashboard sidebar.
enum DashboardSection {
  dashboard(AppRoutes.dashboard, 'Dashboard', Icons.dashboard_rounded),
  aiSupport(AppRoutes.aiSupport, 'AI Support', Icons.auto_awesome),
  teamManagement(
    AppRoutes.teamManagement,
    'Team Management',
    Icons.group_outlined,
    ownerOnly: true,
  ),
  subscription(
    AppRoutes.subscription,
    'Subscription',
    Icons.credit_card,
    ownerOnly: true,
  ),
  profileSettings(
    AppRoutes.profileSettings,
    'Profile Settings',
    Icons.settings_outlined,
  );

  const DashboardSection(
    this.route,
    this.label,
    this.icon, {
    this.ownerOnly = false,
  });

  final String route;
  final String label;
  final IconData icon;

  /// Only organization owners may open these pages.
  final bool ownerOnly;

  static DashboardSection? fromRoute(String route) {
    for (final section in values) {
      if (section.route == route) return section;
    }
    return null;
  }
}
