import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // API HELPERS
  // ---------------------------------------------------------------------------

  Future<String?> _getUserRole(String token) async {
    final url = Uri.parse('https://cashoverflow-api.runasp.net/v1/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('GET /me status: ${response.statusCode}');
      debugPrint('GET /me body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final role = userData['role'] ?? userData['Role'];
        if (role != null) return role.toString();
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION & LOGIC
  // ---------------------------------------------------------------------------

  void _navigateAfterLogin(String? role) {
    if (!mounted) return;

    final normalizedRole = role?.trim().toLowerCase();
    debugPrint('USER ROLE: $normalizedRole');

    if (normalizedRole == 'admin') {
      Navigator.of(context).pushReplacementNamed('/admin-dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final url = Uri.parse('https://cashoverflow-api.runasp.net/v1/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN RESPONSE: ${response.body}');

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint('Invalid JSON response: $e');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = responseData['token']?.toString() ?? '';
        final message = responseData['message']?.toString() ?? 'User logged in successfully';

        if (token.isEmpty) {
          _showErrorSnackBar('Login succeeded but no authentication token was returned.');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', _emailController.text.trim());

        debugPrint('AUTH TOKEN SAVED');

        final role = await _getUserRole(token);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        _navigateAfterLogin(role);
      } else {
        final errorMessage = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Login failed. Please check your credentials.';

        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      _showErrorSnackBar('Network error or server unreachable.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black87,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 64.0,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: _buildGlassCard(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(
            horizontal: 48.0,
            vertical: 40.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF232528).withOpacity(0.75),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Sign in to access your company's financial data and\nAI-powered insights",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0B3B8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // EMAIL FIELD
                _buildInputField(
                  label: 'Email',
                  hint: 'Enter your Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // PASSWORD FIELD
                _buildInputField(
                  label: 'Password',
                  hint: 'Enter your Password',
                  controller: _passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggle: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF8E9297),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // SUBMIT BUTTON
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFA0A5AA),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF6C7075),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF1E2023).withOpacity(0.6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF8E9297),
                      size: 18,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}