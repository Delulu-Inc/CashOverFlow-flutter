import 'dart:ui';
import 'package:flutter/material.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لمعرفة عرض الشاشة الحالية
    final double screenWidth = MediaQuery.of(context).size.width;
    // تحديد ما إذا كانت الشاشة صغيرة (مثل الموبايل)
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
                  // تحديد أقصى عرض للكمبيوتر مع مرونة التكيف مع الهاتف
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 600,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 80.0,
                    vertical: isMobile ? 32.0 : 70.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232528).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // العنوان الرئيسي
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

                      // النص الوصفي
                      Text(
                        'Choose a strong password to keep your account secure.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13.0 : 15.0,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: isMobile ? 24.0 : 32.0),

                      // حقل إدخال كلمة المرور الأول
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

                      // حقل تأكيد كلمة المرور
                      _buildLabel('Confirm Password'),
                      const SizedBox(height: 8.0),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Repeat your password',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),

                      const SizedBox(height: 20.0),

                      // شروط كلمة المرور
                      _buildRequirementItem('At least 8 characters'),
                      const SizedBox(height: 6.0),
                      _buildRequirementItem('Include a number'),
                      const SizedBox(height: 6.0),
                      _buildRequirementItem('Include a special character'),

                      SizedBox(height: isMobile ? 32.0 : 40.0),

                      // زر تعيين كلمة المرور
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
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

  // ودجت المساعدة لكتابة العنوان فوق الحقول
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

  // ودجت المساعدة لحقول الإدخال
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
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
        fillColor: const Color(0xFF1A1C1E).withOpacity(0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.15),
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

  // ودجت المساعدة لقائمة الشروط
  Widget _buildRequirementItem(String text) {
    return Row(
      children: [
        const Text(
          '• ',
          style: TextStyle(color: Colors.white54, fontSize: 14.0),
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.white54, fontSize: 12.5),
        ),
      ],
    );
  }
}
