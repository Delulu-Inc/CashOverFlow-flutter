import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/checkout_session.dart';

/// Stripe checkout for invited companies.
class CheckoutRepository {
  CheckoutRepository({required this._api});

  final ApiClient _api;

  /// `POST /Checkout/create-session` – never throws.
  Future<CheckoutSessionResponse> createCheckoutSession(
    CreateCheckoutSessionRequest request,
  ) async {
    try {
      final response = await _api.post(
        '/Checkout/create-session',
        body: request.toJson(),
        authenticated: false,
      );
      final json = response.json;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          json != null) {
        return CheckoutSessionResponse.fromJson(json);
      }
      return CheckoutSessionResponse.failure(
        response.toException('Error ${response.statusCode}').message,
      );
    } on ApiException catch (error) {
      return CheckoutSessionResponse.failure(error.message);
    }
  }
}
