import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ==========================================
// 1. MODEL
// ==========================================
class SetPasswordRequest {
  final String token;
  final String password;
  final String confirmPassword;

  SetPasswordRequest({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}

// ==========================================
// 2. SERVICE
// ==========================================
class OnboardingService {
  static const String baseUrl = 'https://cashoverflow-api.runasp.net/v1';

  static Future<bool> acceptInvite(SetPasswordRequest request) async {
    final url = Uri.parse('$baseUrl/onboarding/accept-invite');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to set password');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// ==========================================
// 3. UI & WIDGET STATE
// ==========================================
class SetPasswordPage extends StatefulWidget {
  final String? token;
  final String? orgId;

  const SetPasswordPage({super.key, this.token, this.orgId});

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

  // Extracted URL Parameters
  String? _activeToken;
  String? _activeOrgId;

  // Validation States
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

  /// دالة استخراج وتجهيز التوكين والـ OrgID لضمان بقائهما متوفرين
  /// حتى مع الـ Refresh أو Hash Routing
  void _extractParametersFromUrl() {
    String? token = widget.token?.trim();
    String? orgId = widget.orgId?.trim();

    if (token == null || token.isEmpty) {
      final currentUri = Uri.base;

      if (currentUri.hasFragment && currentUri.fragment.isNotEmpty) {
        final fragment = currentUri.fragment;
        final formattedFragment =
            fragment.startsWith('/') ? fragment : '/$fragment';
        final fragmentUri = Uri.parse(formattedFragment);

        token = fragmentUri.queryParameters['token']?.trim();
        orgId ??= fragmentUri.queryParameters['orgId']?.trim();
      } else {
        token = currentUri.queryParameters['token']?.trim();
        orgId ??= currentUri.queryParameters['orgId']?.trim();
      }
    }

    _activeToken = token;
    _activeOrgId = orgId;
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      _passwordsMatch = password.isNotEmpty && password == confirmPassword;
    });
  }

  bool get _isFormValid =>
      _hasMinLength && _hasNumber && _hasSpecialChar && _passwordsMatch;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please satisfy all password requirements'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // التحقق النهائي من التوكين
    final tokenToUse = _activeToken ?? '';

    if (tokenToUse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or missing invitation token.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = SetPasswordRequest(
        token: tokenToUse,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      final success = await OnboardingService.acceptInvite(request);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password set successfully! Redirecting to login...'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.jpg'),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 35.0,
              vertical: isMobile ? 40.0 : 60.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 600,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 80.0,
                    vertical: isMobile ? 32.0 : 70.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232528).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
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
                          onToggleVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 20.0),
                        _buildLabel('Confirm Password'),
                        const SizedBox(height: 8.0),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Repeat your password',
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
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
                        _buildRequirementItem(
                          'Passwords match',
                          _passwordsMatch,
                        ),
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.white : Colors.white54,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}