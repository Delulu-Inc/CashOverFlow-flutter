import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_models.dart';

class SubscriptionService {
  static const String baseUrl = 'https://cashoverflow-api.runasp.net/v1';

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<SubscriptionDetails> getSubscriptionDetails() async {
    final url = Uri.parse('$baseUrl/subscription');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      log('GET $url -> Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return SubscriptionDetails.fromJson(decoded);
        }
      }

      throw Exception(
        'Failed to load subscription details (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      log('Subscription Error: $e');
      rethrow;
    }
  }

  Future<List<BillingHistoryItem>> getBillingHistory() async {
    final url = Uri.parse('$baseUrl/subscription/billing-history');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      log('GET $url -> Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> list = [];

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final nested =
              decoded['data'] ??
              decoded['billingHistory'] ??
              decoded['items'] ??
              decoded['payments'];
          if (nested is List) {
            list = nested;
          }
        }

        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => BillingHistoryItem.fromJson(json))
            .toList();
      }

      throw Exception(
        'Failed to load billing history (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      log('Billing History Error: $e');
      rethrow;
    }
  }

  Future<bool> updatePaymentMethod({
    required String cardholderName,
    required String cardNumber,
    required String expiry,
    required String cvc,
  }) async {
    final url = Uri.parse('$baseUrl/subscription/payment-method');

    try {
      final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

      if (cleanNumber.length < 12) {
        log('Invalid card number length');
        return false;
      }

      final last4 = cleanNumber.substring(cleanNumber.length - 4);
      final cardBrand = _detectCardBrand(cleanNumber);

      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'cardBrand': cardBrand, 'last4': last4}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('Update Payment Error: $e');
      return false;
    }
  }

  String _detectCardBrand(String cleanNumber) {
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(cleanNumber)) {
      return 'MasterCard';
    } else if (RegExp(r'^(34|37)').hasMatch(cleanNumber)) {
      return 'American Express';
    } else if (RegExp(r'^(50|58)').hasMatch(cleanNumber)) {
      return 'Meeza';
    }
    return 'Visa';
  }
}
