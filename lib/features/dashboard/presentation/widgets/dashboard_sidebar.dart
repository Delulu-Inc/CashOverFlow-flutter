import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../dashboard_section.dart';

/// Dark navigation sidebar of the dashboard shell.
class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final DashboardSection current;
  final ValueChanged<DashboardSection> onNavigate;

  Future<void> _logout(BuildContext context) async {
    await context.read<SessionCubit>().signOut();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.sidebarBackground,
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, session) {
          final bool isOwner = session.user?.isOwner ?? false;
          final sections = DashboardSection.values.where(
            (section) => !section.ownerOnly || isOwner,
          );

          // Scrolls on very short screens, keeps the footer pinned otherwise.
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/img/logo.png',
                                width: 26,
                                height: 26,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Cash Overflow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      for (final section in sections)
                        _SidebarNavItem(
                          icon: section.icon,
                          title: section.label,
                          isActive: section == current,
                          onTap: () => onNavigate(section),
                        ),

                      const Spacer(),

                      const Divider(color: Color(0xFF1E293B), height: 1),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _SidebarNavItem(
                          icon: Icons.logout_rounded,
                          title: 'Log out',
                          isLogout: true,
                          onTap: () => _logout(context),
                        ),
                      ),

                      const Divider(color: Color(0xFF1E293B), height: 1),

                      _SidebarUserTile(session: session),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SidebarUserTile extends StatelessWidget {
  const _SidebarUserTile({required this.session});

  final SessionState session;

  @override
  Widget build(BuildContext context) {
    final user = session.user;
    final bool isLoading = session.isResolving;

    final String firstName = switch (session.status) {
      SessionStatus.guest => 'Guest',
      SessionStatus.authenticated => user?.firstName ?? 'User',
      _ => 'User',
    };
    final String lastName = user?.lastName ?? '';
    final String role = user?.displayRole ?? '';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1D4ED8),
              child: Text(
                isLoading ? 'U' : firstName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isLoading
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                firstName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                lastName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (role.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            role,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.isLogout = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout
                      ? Colors.redAccent
                      : (isActive ? Colors.blueAccent : Colors.grey[400]),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isLogout
                          ? Colors.redAccent
                          : (isActive ? Colors.white : Colors.grey[400]),
                      fontSize: 14,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
