/// Body of `POST /Checkout/create-session`.
class CreateCheckoutSessionRequest {
  const CreateCheckoutSessionRequest({
    required this.invitationToken,
    required this.planName,
    required this.amount,
  });

  final String invitationToken;
  final String planName;
  final double amount;

  Map<String, dynamic> toJson() {
    return {
      'invitationToken': invitationToken,
      'planName': planName,
      'amount': amount,
    };
  }
}

/// Stripe checkout session returned by the API.
class CheckoutSessionResponse {
  const CheckoutSessionResponse({
    required this.isSuccess,
    this.sessionId,
    this.checkoutUrl,
    this.amount,
    this.currency,
    this.status,
    this.message,
  });

  final bool isSuccess;
  final String? sessionId;
  final String? checkoutUrl;
  final double? amount;
  final String? currency;
  final String? status;
  final String? message;

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionResponse(
      isSuccess: true,
      sessionId: json['sessionId']?.toString(),
      checkoutUrl: json['checkoutUrl']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
    );
  }

  factory CheckoutSessionResponse.failure(String message) {
    return CheckoutSessionResponse(isSuccess: false, message: message);
  }
}
