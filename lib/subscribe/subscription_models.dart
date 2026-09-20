class SubscriptionDetails {
  final String? id;
  final String? organizationId;
  final String? subscriptionPlan;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? cardBrand;
  final String? last4;

  SubscriptionDetails({
    this.id,
    this.organizationId,
    this.subscriptionPlan,
    this.status,
    this.startDate,
    this.endDate,
    this.cardBrand,
    this.last4,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      id: json['id'] ?? json['Id'] as String?,
      organizationId: json['organizationId'] ??
          json['organization_id'] ??
          json['OrganizationId'] as String?,
      subscriptionPlan: json['subscriptionPlan'] ??
          json['subscription_plan'] ??
          json['SubscriptionPlan'] as String?,
      status: json['status'] ?? json['Status'] as String?,
      startDate: json['startDate'] ??
          json['start_date'] ??
          json['StartDate'] as String?,
      endDate:
          json['endDate'] ?? json['end_date'] ?? json['EndDate'] as String?,
      cardBrand: json['cardBrand'] ??
          json['card_brand'] ??
          json['CardBrand'] as String?,
      last4: json['last4'] ?? json['Last4'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'subscription_plan': subscriptionPlan,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'card_brand': cardBrand,
      'last4': last4,
    };
  }
}

class BillingHistoryItem {
  final String transactionId;
  final String email;
  final String plan;
  final double amount;
  final String status;
  final String date;

  BillingHistoryItem({
    required this.transactionId,
    required this.email,
    required this.plan,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory BillingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BillingHistoryItem(
      transactionId: json['transaction_id'] ?? json['transactionId'] ?? '',
      email: json['email'] ?? '',
      plan: json['plan'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'email': email,
      'plan': plan,
      'amount': amount,
      'status': status,
      'date': date,
    };
  }
}
