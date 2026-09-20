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
  final _countryController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _companySizeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _countryController.dispose();
    _businessTypeController.dispose();
    _companySizeController.dispose();
    super.dispose();
  }

  // دالة إرسال البيانات للـ API
  Future<void> _submitDemoRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://cashoverflow-api.runasp.net/v1/onboarding/demo-request');

    // تجهيز Body بنفس الأسماء المطلوبة بالظبط
    final body = jsonEncode({
      "firstName": _firstnameController.text.trim(),
      "lastName": _lastnameController.text.trim(),
      "companyEmail": _emailController.text.trim(),
      "companyName": _companyNameController.text.trim(),
      "companySize": _companySizeController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "message": _businessTypeController.text.trim(), // تم ربط نوع النشاط بالـ message
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // الانتقال لصفحة النجاح عند اكتمال الطلب بنجاح
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoneAfterSignupPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.jpg'),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 90.0),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
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
                          const SizedBox(height: 80),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              bool isMobile = constraints.maxWidth < 650;

                              Widget personalSection = _buildPersonalSection();
                              Widget businessSection = _buildBusinessSection();

                              if (isMobile) {
                                return Column(
                                  children: [
                                    personalSection,
                                    const SizedBox(height: 40),
                                    businessSection,
                                  ],
                                );
                              } else {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: personalSection),
                                    const SizedBox(width: 150),
                                    Expanded(child: businessSection),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 70),

                          // Register Button المعالج
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitDemoRequest,
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
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 16,
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
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Last Name',
          hint: 'Enter your last name',
          controller: _lastnameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your last name';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Phone',
          hint: 'Enter your phone number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^[0-9+\s\-]{8,15}$').hasMatch(value.trim())) {
              return 'Please enter a valid phone number';
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
            fontSize: 16,
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
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your company name';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Company Email',
          hint: 'Enter your company email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your company email';
            }
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
            );
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Please enter a valid company email address';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Company Size',
          hint: 'Enter your company size',
          controller: _companySizeController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your company size';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Business Type',
          hint: 'Enter your business type',
          controller: _businessTypeController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your business type';
            }
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
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
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
            obscureText: obscureText,
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
      ),
    );
  }
}