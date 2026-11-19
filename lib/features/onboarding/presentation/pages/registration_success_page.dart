import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/auth_background.dart';

/// Shown after the "Register" (demo request) form was submitted.
class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

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
              maxWidth: isMobile ? double.infinity : 650,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 48.0,
                vertical: isMobile ? 32.0 : 40.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Our Team Will Reach\nYou Soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 26.0 : 36.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12.0 : 18.0),
                  Text(
                    isMobile
                        ? 'Our team will contact you to securely collect your company’s financial data, connect it to our AI models, and manage it efficiently.'
                        : 'Our team will contact you to securely collect your\ncompany’s financial data, connect it to our AI models,\nand manage it efficiently.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : 16.0,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 30.0 : 60.0),
                  Center(
                    child: Container(
                      width: isMobile ? 90 : 120,
                      height: isMobile ? 90 : 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: isMobile ? 4 : 5,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: isMobile ? 50 : 70,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 40.0 : 100.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 50,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.landing,
                              (_) => false,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 10.0 : 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
