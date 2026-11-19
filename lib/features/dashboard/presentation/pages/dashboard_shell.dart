import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ai_support/presentation/pages/ai_support_page.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../profile/presentation/pages/profile_settings_page.dart';
import '../../../subscription/presentation/pages/subscription_billing_page.dart';
import '../../../team/presentation/pages/team_management_page.dart';
import '../dashboard_section.dart';
import '../widgets/dashboard_sidebar.dart';
import 'dashboard_page.dart';

/// Layout shared by every signed-in page: sidebar + content.
///
/// Sidebar pages are switched in place (no route transition, the sidebar is
/// never rebuilt) and the browser URL is kept in sync.
///
/// * ≥ [Breakpoints.laptop]: permanent 260px sidebar (Figma layout).
/// * below: compact top bar and the same sidebar inside a drawer.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key, required this.initialSection});

  final DashboardSection initialSection;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  static const double _sidebarWidth = 260;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DashboardSection _current = widget.initialSection;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>();
    session.load();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _enforceAccess(session.state),
    );
  }

  void _select(DashboardSection section) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState!.closeDrawer();
    }
    if (section == _current || !mounted) return;

    setState(() => _current = section);
    SystemNavigator.routeInformationUpdated(uri: Uri.parse(section.route));
    _enforceAccess(context.read<SessionCubit>().state);
  }

  /// Role based access control for owner-only pages.
  void _enforceAccess(SessionState session) {
    if (!mounted) return;
    if (_current.ownerOnly && session.canAccessOwnerPages == false) {
      _select(DashboardSection.dashboard);
    }
  }

  Widget _buildPage(SessionState session) {
    if (_current.ownerOnly && session.canAccessOwnerPages != true) {
      return const ColoredBox(
        color: AppColors.dashboardBackground,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (_current) {
      case DashboardSection.dashboard:
        return DashboardPage(
          onOpenAiSupport: () => _select(DashboardSection.aiSupport),
        );
      case DashboardSection.aiSupport:
        return const AiSupportPage();
      case DashboardSection.teamManagement:
        return TeamManagementPage(
          onAccessDenied: () => _select(DashboardSection.dashboard),
        );
      case DashboardSection.subscription:
        return const SubscriptionBillingPage();
      case DashboardSection.profileSettings:
        return const ProfileSettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPermanentSidebar = context.screenWidth >= Breakpoints.laptop;

    final sidebar = DashboardSidebar(current: _current, onNavigate: _select);

    return Title(
      title: AppConfig.pageTitle(_current.label),
      color: AppColors.brandBlue,
      child: BlocConsumer<SessionCubit, SessionState>(
        listener: (context, session) => _enforceAccess(session),
        builder: (context, session) {
          final page = KeyedSubtree(
            key: ValueKey(_current),
            child: _buildPage(session),
          );

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.dashboardBackground,
            drawer: hasPermanentSidebar
                ? null
                : Drawer(
                    width: _sidebarWidth,
                    backgroundColor: AppColors.sidebarBackground,
                    shape: const RoundedRectangleBorder(),
                    child: sidebar,
                  ),
            body: hasPermanentSidebar
                ? Row(
                    children: [
                      SizedBox(width: _sidebarWidth, child: sidebar),
                      Expanded(child: page),
                    ],
                  )
                : Column(
                    children: [
                      _CompactTopBar(
                        onMenuPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(child: page),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// Top bar shown instead of the sidebar on tablets and phones.
class _CompactTopBar extends StatelessWidget {
  const _CompactTopBar({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sidebarBackground,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: onMenuPressed,
              ),
              const SizedBox(width: 4),
              Image.asset('assets/img/logo.png', width: 24, height: 24),
              const SizedBox(width: 10),
              const Text(
                'Cash Overflow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
