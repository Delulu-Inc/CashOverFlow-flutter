import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ActivatePlanPage extends StatefulWidget {
  const ActivatePlanPage({super.key});

  @override
  State<ActivatePlanPage> createState() => _ActivatePlanPageState();
}

class _ActivatePlanPageState extends State<ActivatePlanPage> {
  // متغير للتحكم في حالة التحميل أثناء استدعاء الـ API
  bool _isLoading = false;

  // دالة التعامل مع عملية الدفع واستدعاء الـ API
  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://cashoverflow-api.runasp.net/v1/Checkout/create-session';

    // تجهيز الـ Body المطلوب في الـ API
    final Map<String, dynamic> requestData = {
      "planName": "Annual Plan",
      "amount": 499,
      "successUrl": "https://yourdomain.com/success", // استبدل بـ URL النجاح الخاص بك
      "cancelUrl": "https://yourdomain.com/cancel",   // استبدل بـ URL الإلغاء الخاص بك
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // افترضنا هنا أن الاستجابة ترجع رابط الدفع باسم checkoutUrl أو url
        final String? checkoutUrl = data['checkoutUrl'] ?? data['url'];

        if (checkoutUrl != null && await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          _showErrorSnackBar('Could not launch payment URL.');
        }
      } else {
        _showErrorSnackBar('Failed to create payment session. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final List<String> features = [
      'Cash-flow forecasting',
      'Risk detection with explanations',
      'AI-powered recommendations',
      'What-if simulations',
      'Role-based permissions',
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.jpg'),
            fit: BoxFit.cover,
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
                      Text(
                        'Activate your plan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 26.0 : 36.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12.0 : 16.0),
                      Text(
                        'Review your plan details and proceed to payment to\nget started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13.0 : 15.0,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24.0 : 36.0),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2023).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash Overflow',
                              style: TextStyle(
                                fontSize: isMobile ? 18.0 : 22.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Annual Plan',
                              style: TextStyle(
                                fontSize: isMobile ? 12.0 : 14.0,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              //crossAxisAlignment: Baseline.,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$499',
                                  style: TextStyle(
                                    fontSize: isMobile ? 28.0 : 34.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  '/year',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12.0 : 14.0,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              'Renews on September 9, 2027',
                              style: TextStyle(
                                fontSize: isMobile ? 11.0 : 13.0,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Column(
                              children: features.map((feature) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: TextStyle(
                                            fontSize: isMobile ? 12.0 : 14.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 24.0 : 36.0),
                      
                      // زر الدفع مع إظهار مؤشر التحميل عند الضغط
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handlePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Proceed to Secure Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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