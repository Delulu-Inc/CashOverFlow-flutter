import 'dart:ui';
import 'package:cash_overflow/Set_password_page.dart';
import 'package:flutter/material.dart';

class DoneAfterSubscripePage extends StatelessWidget {
  final String? sessionId;

  const DoneAfterSubscripePage({
    super.key,
    this.sessionId,
  });

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
                    maxWidth: isMobile ? double.infinity : 650,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 48.0,
                    vertical: isMobile ? 32.0 : 60.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232528).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'You’re all set!',
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
                        'Your subscription has been activated successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : 16.0,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isMobile ? 20.0 : 30.0),
                      Center(
                        child: Container(
                          width: isMobile ? 60 : 80,
                          height: isMobile ? 60 : 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: isMobile ? 2 : 3,
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: isMobile ? 35 : 50,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash Overflow',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16.0 : 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '\$499',
                                      style: TextStyle(
                                        fontSize: isMobile ? 22.0 : 28.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '/year',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12.0 : 14.0,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Everything you need to predict, understand, and stay ahead of your cash.',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12.0 : 13.0,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 0 : 50,
                        ),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SetPasswordPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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
}