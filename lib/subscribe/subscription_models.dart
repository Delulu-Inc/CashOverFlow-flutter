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
      id: json['id']?.toString() ?? json['Id']?.toString(),
      organizationId:
          json['organizationId']?.toString() ??
          json['organization_id']?.toString() ??
          json['OrganizationId']?.toString(),
      subscriptionPlan:
          json['subscriptionPlan']?.toString() ??
          json['subscription_plan']?.toString() ??
          json['SubscriptionPlan']?.toString(),
      status: json['status']?.toString() ?? json['Status']?.toString(),
      startDate:
          json['startDate']?.toString() ??
          json['start_date']?.toString() ??
          json['StartDate']?.toString(),
      endDate:
          json['endDate']?.toString() ??
          json['end_date']?.toString() ??
          json['EndDate']?.toString(),
      cardBrand:
          json['cardBrand']?.toString() ??
          json['card_brand']?.toString() ??
          json['CardBrand']?.toString(),
      last4: json['last4']?.toString() ?? json['Last4']?.toString(),
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
      transactionId:
          (json['transaction_id'] ?? json['transactionId'] ?? json['id'] ?? '')
              .toString(),
      email: (json['email'] ?? json['userEmail'] ?? 'N/A').toString(),
      plan: (json['plan'] ?? json['subscriptionPlan'] ?? 'Pro').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'Succeeded').toString(),
      date: (json['date'] ?? json['createdAt'] ?? '').toString(),
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
