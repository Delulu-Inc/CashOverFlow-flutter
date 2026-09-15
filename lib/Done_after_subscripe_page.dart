import 'dart:ui';
import 'package:flutter/material.dart';

class DoneAfterSubscripePage extends StatelessWidget {
  const DoneAfterSubscripePage({super.key});

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
                    maxWidth: isMobile ? double.infinity : 650,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 48.0,
                    vertical: isMobile ? 32.0 : 90.0,
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
                      // العنوان الرئيسي كـ Text واحد متصل
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

                      // النص الوصفي كـ Text واحد متصل وينزل تلقائياً حسب العرض
                      Text(
                        'Your subscription has been activated successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : 16.0,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: isMobile ? 15.0 : 30.0),

                      // أيقونة التأكيد بحجم متجاوب
                      Center(
                        child: Container(
                          width: isMobile ? 55 : 80,
                          height: isMobile ? 55 : 80,
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
                            size: isMobile ? 30 : 50,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: isMobile
                              ? const EdgeInsets.all(25)
                              : const EdgeInsets.all(50),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white24,
                                width: isMobile ? 1 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 25,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Cash Overflow',
                                        style: TextStyle(
                                          fontSize: isMobile ? 16.0 : 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$499',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isMobile ? 20.0 : 28.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 2.0 : 6.0),
                                      Text(
                                        '/year',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: isMobile ? 10.0 : 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isMobile ? 5.0 : 10.0),
                                  Text(
                                    'Everything you need to predict, understand, and stay ahead of your cash.',
                                    style: TextStyle(
                                      fontSize: isMobile ? 10.0 : 11.8,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: SizedBox(
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
