import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/team_member.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../data/repositories/team_repository.dart';
import '../widgets/invite_member_dialog.dart';
import '../widgets/remove_member_dialog.dart';

/// Owner-only page listing the accounts that can access the dashboard.
class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key, this.onAccessDenied});

  /// Called when the API refuses access (the user is not an owner).
  final VoidCallback? onAccessDenied;

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  static const Color _headingColor = Color(0xFF1E3A8A);

  late Future<List<TeamMember>> _teamMembersFuture;

  /// Members whose access is being revoked.
  final Set<String> _removingIds = {};

  /// E-mail of the signed-in user (owners cannot remove themselves).
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _teamMembersFuture = _fetchTeamMembers();
  }

  Future<List<TeamMember>> _fetchTeamMembers() async {
    try {
      return await context.read<TeamRepository>().fetchMembers();
    } on ApiException catch (error) {
      if (error.isAccessDenied &&
          !identical(error, ApiException.missingSession)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onAccessDenied?.call();
        });
        return const [];
      }
      rethrow;
    }
  }

  Future<void> _openInviteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const InviteMemberDialog(),
    );
    if (result == true && mounted) {
      setState(() {
        _teamMembersFuture = _fetchTeamMembers();
      });
    }
  }

  Future<void> _confirmRemoveMember(TeamMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RemoveMemberDialog(member: member),
    );
    if (confirmed != true || !mounted) return;

    final repository = context.read<TeamRepository>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _removingIds.add(member.id));

    try {
      await repository.removeMember(member.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Access removed for ${member.name}.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _teamMembersFuture = _fetchTeamMembers();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _removingIds.remove(member.id));
    }
  }

  bool _isCurrentUser(TeamMember member) {
    final email = _currentUserEmail;
    return email != null && email.toLowerCase() == member.email.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    _currentUserEmail = context.select(
      (SessionCubit cubit) => cubit.state.user?.email,
    );

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(compact: isMobile),
              SizedBox(height: isMobile ? 24 : 32),

              // Members card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accounts with access',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _headingColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<TeamMember>>(
                      future: _teamMembersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Error loading team members: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text('No team members found.'),
                            ),
                          );
                        }

                        final members = snapshot.data!;
                        return LayoutBuilder(
                          builder: (context, constraints) =>
                              constraints.maxWidth < 640
                              ? _buildMemberCards(members)
                              : _buildMembersTable(members),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool compact}) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _headingColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage accounts with access to your organization's dashboard.",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );

    final inviteButton = ElevatedButton.icon(
      onPressed: _openInviteDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text(
        'Invite',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 16), inviteButton],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        inviteButton,
      ],
    );
  }

  Widget _buildRemoveAccessButton(TeamMember member) {
    final bool isRemoving = _removingIds.contains(member.id);
    final bool isSelf = _isCurrentUser(member);
    final bool enabled = !isRemoving && !isSelf && member.id.isNotEmpty;

    final button = OutlinedButton.icon(
      onPressed: enabled ? () => _confirmRemoveMember(member) : null,
      style:
          OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ).copyWith(
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled) && !isRemoving
                    ? Colors.grey.shade300
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
      icon: isRemoving
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFDC2626),
              ),
            )
          : const Icon(Icons.delete_outline, size: 16),
      label: const Text(
        'Remove access',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );

    if (!isSelf) return button;
    return Tooltip(message: 'You cannot remove your own access', child: button);
  }

  /// Desktop / tablet: the Figma table.
  Widget _buildMembersTable(List<TeamMember> members) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: _headingColor,
      fontSize: 14,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Name', style: headerStyle)),
                Expanded(flex: 4, child: Text('Email', style: headerStyle)),
                Expanded(flex: 3, child: Text('Position', style: headerStyle)),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Action', style: headerStyle),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final member = members[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        member.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        member.position,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildRemoveAccessButton(member),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Phones: one card per member, same typography as the table.
  Widget _buildMemberCards(List<TeamMember> members) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < members.length; i++) ...[
            if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    members[i].name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    members[i].email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    members[i].position,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRemoveAccessButton(members[i]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
