import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ==========================================
// 1. MODELS
// ==========================================

class CreateCheckoutSessionRequest {
  final String planName;
  final double amount;
  final String successUrl;
  final String cancelUrl;

  CreateCheckoutSessionRequest({
    required this.planName,
    required this.amount,
    required this.successUrl,
    required this.cancelUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'amount': amount,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    };
  }
}

class CheckoutSessionResponse {
  final bool isSuccess;
  final String? sessionId;
  final String? checkoutUrl;
  final String? message;

  CheckoutSessionResponse({
    required this.isSuccess,
    this.sessionId,
    this.checkoutUrl,
    this.message,
  });

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionResponse(
      isSuccess: true,
      sessionId: json['sessionId'] ?? json['id'],
      checkoutUrl: json['checkoutUrl'] ?? json['url'],
      message: json['message'],
    );
  }
}

// ==========================================
// 2. CHECKOUT SERVICE
// ==========================================

class CheckoutService {
  final String baseUrl;

  CheckoutService({this.baseUrl = 'https://cashoverflow-api.runasp.net/v1'});

  Future<CheckoutSessionResponse> createCheckoutSession({
    required CreateCheckoutSessionRequest request,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/Checkout/create-session');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CheckoutSessionResponse.fromJson(data);
      } else {
        return CheckoutSessionResponse(
          isSuccess: false,
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return CheckoutSessionResponse(
        isSuccess: false,
        message: 'Network error: $e',
      );
    }
  }
}

// ==========================================
// 3. UI WIDGET (ACTIVATE PLAN PAGE)
// ==========================================

class ActivatePlan extends StatefulWidget {
  final String? inviteToken;
  final String? userToken;

  const ActivatePlan({super.key, this.userToken, this.inviteToken});

  @override
  State<ActivatePlan> createState() => _ActivatePlanState();
}

class _ActivatePlanState extends State<ActivatePlan> {
  final CheckoutService _checkoutService = CheckoutService();
  bool _isLoading = false;

  final String _planName = 'Annual Plan';
  final double _amount = 499.0;

  Future<void> _handleProceedToPayment() async {
    setState(() => _isLoading = true);

    final request = CreateCheckoutSessionRequest(
      planName: _planName,
      amount: _amount,
      successUrl: 'https://delulu-inc.github.io/CashOverFlow-flutter/#/payment-success',
      cancelUrl: 'https://delulu-inc.github.io/CashOverFlow-flutter/#/payment-failed',
    );

    final response = await _checkoutService.createCheckoutSession(
      request: request,
      token: widget.userToken,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session created successfully! ID: ${response.sessionId ?? "OK"}'),
          backgroundColor: Colors.green,
        ),
      );

      // هنا يمكنك توجيه المستخدم لصفحة تفاصيل الدفع أو فتح رابط الـ CheckoutUrl إذا كان الباك إند يعيد رابط
      /*
      if (response.checkoutUrl != null) {
        // Open URL in webview or browser
      } else {
        // Navigate to internal payment screen
      }
      */
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Failed to create session'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                    maxWidth: isMobile ? double.infinity : 650,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 48.0,
                    vertical: isMobile ? 32.0 : 40.0,
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
                        'Activate your plan',
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
                        'Review your plan details and proceed to payment to\nget started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : 16.0,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24.0 : 32.0),
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cash Overflow',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _planName,
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$${_amount.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                const Text(
                                  '/year',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Renews on September 9, 2027',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white54,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(color: Colors.white24, height: 1),
                            ),
                            const _PlanFeatureItem(
                              text: 'Cash-flow forecasting',
                            ),
                            const SizedBox(height: 10.0),
                            const _PlanFeatureItem(
                              text: 'Risk detection with explanations',
                            ),
                            const SizedBox(height: 10.0),
                            const _PlanFeatureItem(
                              text: 'AI-powered recommendations',
                            ),
                            const SizedBox(height: 10.0),
                            const _PlanFeatureItem(
                              text: 'What-if simulations',
                            ),
                            const SizedBox(height: 10.0),
                            const _PlanFeatureItem(
                              text: 'Role-based permissions',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 30.0 : 40.0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 0 : 50,
                        ),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleProceedToPayment,
                            
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
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Proceed to Secure Payment',
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
        ),
      ),
    );
  }
}

// ==========================================
// 4. HELPER WIDGET
// ==========================================

class _PlanFeatureItem extends StatelessWidget {
  final String text;

  const _PlanFeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, color: Colors.blueAccent, size: 16.0),
        const SizedBox(width: 10.0),
        Text(
          text,
          style: const TextStyle(fontSize: 13.0, color: Colors.white70),
        ),
      ],
    );
  }
}