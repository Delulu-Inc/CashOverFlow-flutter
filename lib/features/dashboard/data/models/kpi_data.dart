/// Headline KPIs returned by `GET /kpis`.
class KpiData {
  const KpiData({
    required this.cashOnHand,
    required this.minCashBuffer,
    required this.receivablesOutstanding,
    required this.receivablesOverdue,
    required this.payablesOutstanding,
    required this.creditLineAvailable,
  });

  final double cashOnHand;
  final double minCashBuffer;
  final double receivablesOutstanding;
  final double receivablesOverdue;
  final double payablesOutstanding;
  final double creditLineAvailable;

  factory KpiData.fromJson(Map<String, dynamic> json) {
    double read(String key) => (json[key] as num?)?.toDouble() ?? 0.0;

    return KpiData(
      cashOnHand: read('cashOnHand'),
      minCashBuffer: read('minCashBuffer'),
      receivablesOutstanding: read('receivablesOutstanding'),
      receivablesOverdue: read('receivablesOverdue'),
      payablesOutstanding: read('payablesOutstanding'),
      creditLineAvailable: read('creditLineAvailable'),
    );
  }
}
