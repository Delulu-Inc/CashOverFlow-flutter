import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PaymentDetailsPage extends StatefulWidget {
  final String planName;
  final double amount;
  final String authToken;

  const PaymentDetailsPage({
    super.key,
    required this.planName,
    required this.amount,
    required this.authToken,
  });

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  String _detectCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(cleanNumber)) {
      return 'MasterCard';
    } else if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      return 'American Express';
    } else if (cleanNumber.startsWith('6')) {
      return 'Discover';
    }
    return 'Unknown';
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final rawCardNumber = _cardController.text.trim().replaceAll(' ', '');
    final last4Digits = rawCardNumber.substring(rawCardNumber.length - 4);
    final cardBrand = _detectCardBrand(rawCardNumber);

    try {
      final response = await http.post(
        Uri.parse('https://your-domain.com/v1/checkout/process-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode({
          "planName": widget.planName,
          "amount": widget.amount,
          "cardBrand": cardBrand,
          "last4": last4Digits,
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process payment'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient / Dark Pattern
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F12), Color(0xFF1B1B22)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Centered Dialog Form UI
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 440,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Payment details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Enter your card information to complete the payment\nprocess securely.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cardholder Name
                      const Text(
                        'Cardholder Name',
                        style: TextStyle(fontSize: 12, color: Color(0xFFB3B3B3)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: _buildInputDecoration('Enter cardholder name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter cardholder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Card Number
                      const Text(
                        'Card Number',
                        style: TextStyle(fontSize: 12, color: Color(0xFFB3B3B3)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cardController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: _buildInputDecoration('Enter your card number'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter card number';
                          }
                          final cleanCard = value.replaceAll(RegExp(r'\s+'), '');
                          if (cleanCard.length < 12 || cleanCard.length > 16) {
                            return 'Card number must be between 12 and 16 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expiry & CVC Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expiry',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFB3B3B3)),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(5),
                                    _ExpiryDateFormatter(),
                                  ],
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                  decoration: _buildInputDecoration('MM/YY'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter expiry';
                                    }
                                    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value.trim())) {
                                      return 'Invalid format';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CVC',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFB3B3B3)),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _cvcController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                  decoration: _buildInputDecoration('123'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter CVC';
                                    }
                                    if (!RegExp(r'^\d{3,4}$').hasMatch(value.trim())) {
                                      return 'Invalid CVC';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Pay Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handlePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
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
                                  'Pay',
                                  style: TextStyle(
                                    fontSize: 14,
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
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF2A2A32),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3D3D48)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3D3D48)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(fontSize: 10, color: Colors.redAccent),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    var newString = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) newString += '/';
      newString += text[i];
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}