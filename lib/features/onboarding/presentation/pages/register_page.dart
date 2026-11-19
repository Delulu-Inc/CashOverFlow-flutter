import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../data/models/demo_request_form.dart';
import '../../data/repositories/onboarding_repository.dart';

/// Public "Register" form – sends a demo request to the sales team.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final form = DemoRequestForm(
      firstName: _firstnameController.text.trim(),
      lastName: _lastnameController.text.trim(),
      companyEmail: _emailController.text.trim(),
      companyName: _companyNameController.text.trim(),
      companySize: _companySizeController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      businessType: _businessTypeController.text.trim(),
    );

    try {
      await context.read<OnboardingRepository>().submitDemoRequest(form);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.registrationSuccess);
    } on ApiException catch (error) {
      if (mounted) _showSnackBar(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final isMobile = context.isMobile;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: GlassCard(
                maxWidth: 1000,
                opacity: 0.80,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20.0 : 32.0,
                  vertical: isMobile ? 32.0 : 40.0,
                ),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 32,
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
                        SizedBox(height: isMobile ? 28 : 40),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final personalSection = _buildPersonalSection();
                            final businessSection = _buildBusinessSection();

                            if (constraints.maxWidth < 700) {
                              return Column(
                                children: [
                                  personalSection,
                                  const SizedBox(height: 30),
                                  businessSection,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: personalSection),
                                const SizedBox(width: 40),
                                Expanded(child: businessSection),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: isMobile ? 32 : 50),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double btnWidth = constraints.maxWidth < 600
                                ? double.infinity
                                : 280;
                            return SizedBox(
                              width: btnWidth,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _submitDemoRequest,
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
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'First Name',
          hint: 'Enter your first name',
          controller: _firstnameController,
          maxLength: 100,
          autofillHints: const [AutofillHints.givenName],
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your first name';
            if (trimmed.length < 2) {
              return 'First name must be at least 2 characters';
            }
            if (!Validators.isPersonName(trimmed)) {
              return 'First name must contain letters only, no numbers allowed';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Last Name',
          hint: 'Enter your last name',
          controller: _lastnameController,
          maxLength: 100,
          autofillHints: const [AutofillHints.familyName],
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your last name';
            if (trimmed.length < 2) {
              return 'Last name must be at least 2 characters';
            }
            if (!Validators.isPersonName(trimmed)) {
              return 'Last name must contain letters only, no numbers allowed';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Phone Number',
          hint: 'e.g. +1234567890',
          controller: _phoneController,
          maxLength: 20,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your phone number';
            if (!Validators.isPhoneNumber(trimmed)) {
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
        _buildSectionTitle('Business Information'),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Company Name',
          hint: 'Enter your company name',
          controller: _companyNameController,
          maxLength: 150,
          autofillHints: const [AutofillHints.organizationName],
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your company name';
            if (trimmed.length < 2) {
              return 'Company name must be at least 2 characters';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Company Email',
          hint: 'name@company.com',
          controller: _emailController,
          maxLength: 256,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter your company email';
            if (!Validators.isEmail(trimmed)) {
              return 'Please enter a valid email address (e.g. name@company.com)';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Company Size (Number of Employees)',
          hint: 'e.g. 50',
          controller: _companySizeController,
          maxLength: 50,
          keyboardType: TextInputType.number,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter company size';
            if (!Validators.isDigitsOnly(trimmed)) {
              return 'Company size must contain numbers only, letters are not allowed';
            }
            return null;
          },
        ),
        _buildInputField(
          label: 'Business Type',
          hint: 'e.g. Fintech, Healthcare, E-commerce',
          controller: _businessTypeController,
          maxLength: 1000,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitDemoRequest(),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Please enter business type';
            if (trimmed.length < 2) {
              return 'Business type must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    TextInputAction textInputAction = TextInputAction.next,
    Iterable<String>? autofillHints,
    ValueChanged<String>? onSubmitted,
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
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: [
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            onFieldSubmitted: onSubmitted,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6C7075),
                fontSize: 13,
              ),
              errorMaxLines: 3,
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
