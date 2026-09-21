//import 'dart0/convert';
import 'dart:convert';
import 'dart:ui';
import 'package:cash_overflow/Done_after_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companySizeController = TextEditingController();
  final _businessTypeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _companySizeController.dispose();
    _businessTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitDemoRequest() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://cashoverflow-api.runasp.net/v1/onboarding/demo-request',
    );

    final body = jsonEncode({
      "firstName": _firstnameController.text.trim(),
      "lastName": _lastnameController.text.trim(),
      "companyEmail": _emailController.text.trim(),
      "companyName": _companyNameController.text.trim(),
      "companySize": _companySizeController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "message": _businessTypeController.text.trim(),
    });

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoneAfterSignupPage(),
          ),
        );
      } else {
        String errorMessage = 'Registration failed. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}

        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Network error. Please check your connection.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 40.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232528).withOpacity(0.80),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Fill in your information and we will get in touch shortly to complete your setup.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0B3B8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              bool isMobile = constraints.maxWidth < 700;

                              Widget personalSection = _buildPersonalSection();
                              Widget businessSection = _buildBusinessSection();

                              if (isMobile) {
                                return Column(
                                  children: [
                                    personalSection,
                                    const SizedBox(height: 30),
                                    businessSection,
                                  ],
                                );
                              } else {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: personalSection),
                                    const SizedBox(width: 40),
                                    Expanded(child: businessSection),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 50),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              double btnWidth = constraints.maxWidth < 600
                                  ? double.infinity
                                  : 280;
                              return SizedBox(
                                width: btnWidth,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _submitDemoRequest,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          'Register',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
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
      ),
    );
  }

  Widget _buildPersonalSection() {
    final nameRegex = RegExp(r'^[a-zA-Z\s\u0600-\u06FF]+$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'First Name',
          hint: 'Enter your first name',
          controller: _firstnameController,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your first name';
            if (trimmed.length < 2) return 'First name must be at least 2 characters';
            if (!nameRegex.hasMatch(trimmed)) {
              return 'First name must contain letters only, no numbers allowed';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Last Name',
          hint: 'Enter your last name',
          controller: _lastnameController,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your last name';
            if (trimmed.length < 2) return 'Last name must be at least 2 characters';
            if (!nameRegex.hasMatch(trimmed)) {
              return 'Last name must contain letters only, no numbers allowed';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Phone Number',
          hint: 'e.g. +1234567890',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your phone number';
            
            final phoneRegex = RegExp(r'^\+?[1-9]\d{6,14}$');
            if (!phoneRegex.hasMatch(trimmed)) {
              return 'Please enter a valid international phone number (e.g. +1234567890)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBusinessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Company Name',
          hint: 'Enter your company name',
          controller: _companyNameController,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your company name';
            if (trimmed.length < 2) return 'Company name must be at least 2 characters';
            return null;
          },
        ),
        _buildInputField(
          label: 'Company Email',
          hint: 'name@company.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your company email';
            
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(trimmed)) {
              return 'Please enter a valid email address (e.g. name@company.com)';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Company Size (Number of Employees)',
          hint: 'e.g. 50',
          controller: _companySizeController,
          keyboardType: TextInputType.number,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter company size';
            
            final numericRegex = RegExp(r'^[0-9]+$');
            if (!numericRegex.hasMatch(trimmed)) {
              return 'Company size must contain numbers only, letters are not allowed';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Business Type',
          hint: 'e.g. Fintech, Healthcare, E-commerce',
          controller: _businessTypeController,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter business type';
            if (trimmed.length < 2) return 'Business type must be at least 2 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFA0A5AA)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6C7075),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF1E2023).withValues(alpha: .6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: .18),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}