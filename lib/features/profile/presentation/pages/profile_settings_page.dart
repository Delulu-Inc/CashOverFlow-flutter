import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/profile_input_field.dart';

/// Personal information & password of the signed-in user.
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  /// Fields of a row are stacked below this card width.
  static const double _stackFieldsBelow = 640;

  static const String _staticAvatarUrl =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop';

  final _personalFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  bool _isLoadingFetch = true;
  bool _isLoadingPersonal = false;
  bool _isLoadingSecurity = false;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _idController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatRole(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final trimmed = raw.trim();
    if (trimmed.toLowerCase() == 'financemanager') return 'Finance Manager';
    return trimmed;
  }

  Future<void> _fetchUserProfile() async {
    final authRepository = context.read<AuthRepository>();

    if (!await authRepository.hasSession) {
      _showSnackBar(
        'Authentication token missing. Please log in again.',
        Colors.red,
      );
      if (mounted) setState(() => _isLoadingFetch = false);
      return;
    }

    try {
      final user = await authRepository.fetchCurrentUser();
      if (!mounted) return;
      setState(() {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email ?? '';
        _positionController.text = _formatRole(user.role ?? user.jobTitle);
        _idController.text = user.companyId ?? '';
      });
    } on ApiException catch (error) {
      _showSnackBar(error.message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingFetch = false);
    }
  }

  Future<void> _updateProfileInfo() async {
    if (_isLoadingPersonal || !_personalFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoadingPersonal = true);
    final profileRepository = context.read<ProfileRepository>();
    final sessionCubit = context.read<SessionCubit>();

    try {
      await profileRepository.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        avatarUrl: _staticAvatarUrl,
      );
      _showSnackBar('Personal profile updated successfully!', Colors.green);
      // Refresh the name displayed in the sidebar.
      sessionCubit.load(force: true);
    } on ApiException catch (error) {
      _showSnackBar(error.message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingPersonal = false);
    }
  }

  Future<void> _changePassword() async {
    if (_isLoadingSecurity || !_securityFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoadingSecurity = true);

    try {
      await context.read<ProfileRepository>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _showSnackBar('Password changed successfully!', Colors.green);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on ApiException catch (error) {
      _showSnackBar(error.message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingSecurity = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: _isLoadingFetch
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
              child: Column(
                children: [
                  _buildPersonalInformationCard(isMobile),
                  const SizedBox(height: 24),
                  _buildSecurityInformationCard(isMobile),
                ],
              ),
            ),
    );
  }

  /// Two fields side by side, stacked on narrow cards.
  Widget _buildFieldRow(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _stackFieldsBelow) {
          return Column(children: [first, const SizedBox(height: 16), second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 20),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
  );

  Widget _buildPersonalInformationCard(bool isMobile) {
    final String fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    final String displayName = fullName.isNotEmpty
        ? fullName
        : (_emailController.text.isNotEmpty
              ? _emailController.text.split('@')[0]
              : 'User');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: _cardDecoration,
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: TextStyle(
                fontSize: isMobile ? 22 : 25,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _positionController.text,
              style: TextStyle(fontSize: 17, color: Colors.grey[600]),
            ),
            SizedBox(height: isMobile ? 32 : 45),
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldRow(
              ProfileInputField(
                label: 'First Name',
                controller: _firstNameController,
                autofillHints: const [AutofillHints.givenName],
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              ProfileInputField(
                label: 'Last Name',
                controller: _lastNameController,
                autofillHints: const [AutofillHints.familyName],
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldRow(
              ProfileInputField(
                label: 'Position',
                controller: _positionController,
                readOnly: true,
                isLocked: true,
              ),
              ProfileInputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                isLocked: true,
              ),
            ),
            const SizedBox(height: 24),
            _buildSaveButton(
              isLoading: _isLoadingPersonal,
              onPressed: _updateProfileInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInformationCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: _cardDecoration,
      child: Form(
        key: _securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldRow(
              ProfileInputField(
                label: 'Current Password',
                controller: _currentPasswordController,
                hintText: 'Enter current password',
                isPassword: true,
                obscureText: _obscureCurrentPassword,
                preventAutofill: true,
                onToggleVisibility: () => setState(
                  () => _obscureCurrentPassword = !_obscureCurrentPassword,
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter current password'
                    : null,
              ),
              ProfileInputField(
                label: 'Company / Org ID',
                controller: _idController,
                readOnly: true,
                isLocked: true,
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldRow(
              ProfileInputField(
                label: 'New Password',
                controller: _newPasswordController,
                hintText: 'Enter new password',
                isPassword: true,
                obscureText: _obscureNewPassword,
                autofillHints: const [AutofillHints.newPassword],
                onToggleVisibility: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter new password';
                  if (val.length < 6) return 'Password too short';
                  return null;
                },
              ),
              ProfileInputField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                hintText: 'Re-enter new password',
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                autofillHints: const [AutofillHints.newPassword],
                onToggleVisibility: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                validator: (val) => val != _newPasswordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildSaveButton(
              isLoading: _isLoadingSecurity,
              onPressed: _changePassword,
            ),
          ],
        ),
      ),
    );
  }
}
