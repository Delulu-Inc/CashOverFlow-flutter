import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/subscription_models.dart';

/// Subscription, payment method and billing history of the organization.
class SubscriptionRepository {
  SubscriptionRepository({required this._api});

  final ApiClient _api;

  /// `GET /subscription`
  Future<SubscriptionDetails> fetchSubscriptionDetails() async {
    final response = await _api.get('/subscription');
    final json = response.json;

    if (response.statusCode == 200 && json != null) {
      return SubscriptionDetails.fromJson(json);
    }
    throw response.toException(
      'Failed to load subscription details (${response.statusCode})',
    );
  }

  /// `GET /subscription/billing-history`
  Future<List<BillingHistoryItem>> fetchBillingHistory() async {
    final response = await _api.get('/subscription/billing-history');

    if (response.statusCode == 200) {
      final decoded = response.data;
      Object? list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        list =
            decoded['data'] ??
            decoded['billingHistory'] ??
            decoded['items'] ??
            decoded['payments'];
      }

      return (list is List ? list : const [])
          .whereType<Map<String, dynamic>>()
          .map(BillingHistoryItem.fromJson)
          .toList();
    }

    throw response.toException(
      'Failed to load billing history (${response.statusCode})',
    );
  }

  /// `PUT /subscription/payment-method`
  ///
  /// Only the card brand and the last four digits ever leave the device.
  Future<bool> updatePaymentMethod({required String cardNumber}) async {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 12) return false;

    try {
      final response = await _api.put(
        '/subscription/payment-method',
        body: {
          'cardBrand': detectCardBrand(cleanNumber),
          'last4': cleanNumber.substring(cleanNumber.length - 4),
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on ApiException {
      return false;
    }
  }

  static String detectCardBrand(String cleanNumber) {
    if (cleanNumber.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(cleanNumber)) return 'MasterCard';
    if (RegExp(r'^(34|37)').hasMatch(cleanNumber)) return 'American Express';
    if (RegExp(r'^(50|58)').hasMatch(cleanNumber)) return 'Meeza';
    return 'Visa';
  }
}
