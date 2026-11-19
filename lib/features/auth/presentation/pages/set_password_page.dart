import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../team/data/repositories/team_repository.dart';
import '../../data/models/set_password_request.dart';

/// Final step of an invitation: the user chooses a password.
///
/// * `type=team` → invited team member (`/team/accept-invite`)
/// * otherwise   → company owner after checkout (`/onboarding/accept-invite`)
class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key, this.token, this.orgId, this.type});

  final String? token;
  final String? orgId;
  final String? type;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _activeToken;
  String? _activeType;

  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _extractParametersFromUrl();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  void _extractParametersFromUrl() {
    String? token = widget.token?.trim();
    String? type = widget.type?.trim();

    final currentUri = Uri.base;

    // 1. Hash fragment (Flutter web default: /#/set-password?token=...)
    if (currentUri.hasFragment && currentUri.fragment.isNotEmpty) {
      final fragment = currentUri.fragment.startsWith('/')
          ? currentUri.fragment
          : '/${currentUri.fragment}';
      final fragmentUri = Uri.parse(fragment);

      token ??= fragmentUri.queryParameters['token']?.trim();
      type ??= fragmentUri.queryParameters['type']?.trim();
    }

    // 2. Standard query parameters
    token ??= currentUri.queryParameters['token']?.trim();
    type ??= currentUri.queryParameters['type']?.trim();

    _activeToken = (token == null || token.isEmpty) ? null : token;
    _activeType = type;
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = Validators.hasNumber(password);
      _hasSpecialChar = Validators.hasSpecialCharacter(password);
      _passwordsMatch = password.isNotEmpty && password == confirmPassword;
    });
  }

  bool get _isFormValid =>
      _hasMinLength && _hasNumber && _hasSpecialChar && _passwordsMatch;

  void _showSnackBar(String message, {Color color = Colors.redAccent}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      _showSnackBar('Please satisfy all password requirements');
      return;
    }

    final onboardingRepository = context.read<OnboardingRepository>();
    final teamRepository = context.read<TeamRepository>();

    // Owners coming back from Stripe have no token in the URL: use the
    // invitation remembered before the checkout redirect.
    final tokenToUse =
        _activeToken ?? await onboardingRepository.pendingInviteToken ?? '';

    if (!mounted) return;
    if (tokenToUse.isEmpty) {
      _showSnackBar('Invalid or missing invitation token.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = SetPasswordRequest(
        token: tokenToUse,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (_activeType?.toLowerCase() == 'team') {
        await teamRepository.acceptInvite(request);
      } else {
        await onboardingRepository.acceptInvite(request);
      }
      await onboardingRepository.clearPendingInviteToken();

      if (!mounted) return;
      _showSnackBar(
        'Password set successfully! Redirecting to login...',
        color: Colors.green,
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } on ApiException catch (error) {
      if (mounted) _showSnackBar(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 35.0,
              vertical: isMobile ? 40.0 : 60.0,
            ),
            child: GlassCard(
              maxWidth: isMobile ? double.infinity : 600,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 80.0,
                vertical: isMobile ? 32.0 : 70.0,
              ),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Set your password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 26.0 : 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Choose a strong password to complete your account setup.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13.0 : 15.0,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24.0 : 32.0),
                      _buildLabel('Password'),
                      const SizedBox(height: 8.0),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Create your password',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        onToggleVisibility: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      const SizedBox(height: 20.0),
                      _buildLabel('Confirm Password'),
                      const SizedBox(height: 8.0),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Repeat your password',
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (_isFormValid) _submitForm();
                        },
                        onToggleVisibility: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                      ),
                      const SizedBox(height: 20.0),
                      _buildRequirementItem(
                        'At least 8 characters',
                        _hasMinLength,
                      ),
                      const SizedBox(height: 6.0),
                      _buildRequirementItem('Include a number', _hasNumber),
                      const SizedBox(height: 6.0),
                      _buildRequirementItem(
                        'Include a special character',
                        _hasSpecialChar,
                      ),
                      const SizedBox(height: 6.0),
                      _buildRequirementItem('Passwords match', _passwordsMatch),
                      SizedBox(height: isMobile ? 32.0 : 40.0),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isFormValid)
                              ? null
                              : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white38,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Set Password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      autofillHints: const [AutofillHints.newPassword],
      style: const TextStyle(color: Colors.white, fontSize: 14.0),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14.0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(0xFF1A1C1E).withValues(alpha: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white54, width: 1),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: isValid ? Colors.greenAccent : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.white : Colors.white54,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}
