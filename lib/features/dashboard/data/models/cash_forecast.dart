/// One day of the cash forecast returned by `GET /forecast`.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.expectedCash,
    required this.pessimisticCash,
    required this.optimisticCash,
    required this.netCashFlow,
  });

  final DateTime date;
  final double expectedCash;
  final double pessimisticCash;
  final double optimisticCash;
  final double netCashFlow;

  /// Returns `null` for malformed rows instead of crashing the whole chart.
  static DailyForecast? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final date = DateTime.tryParse(raw['date']?.toString() ?? '');
    final expected = raw['expectedCash'];
    if (date == null || expected is! num) return null;

    double read(String key) =>
        (raw[key] as num?)?.toDouble() ?? expected.toDouble();

    return DailyForecast(
      date: date,
      expectedCash: expected.toDouble(),
      pessimisticCash: read('pessimisticCash'),
      optimisticCash: read('optimisticCash'),
      netCashFlow: (raw['netCashFlow'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CashForecastData {
  const CashForecastData({
    required this.startCashOnHand,
    required this.minCashBuffer,
    required this.horizonDays,
    required this.dailyForecast,
  });

  final double startCashOnHand;
  final double minCashBuffer;
  final int horizonDays;
  final List<DailyForecast> dailyForecast;

  factory CashForecastData.fromJson(Map<String, dynamic> json) {
    final rows = json['dailyForecast'];
    return CashForecastData(
      startCashOnHand: (json['startCashOnHand'] as num?)?.toDouble() ?? 0.0,
      minCashBuffer: (json['minCashBuffer'] as num?)?.toDouble() ?? 0.0,
      horizonDays: (json['horizonDays'] as num?)?.toInt() ?? 30,
      dailyForecast: rows is List
          ? rows.map(DailyForecast.tryParse).whereType<DailyForecast>().toList()
          : const [],
    );
  }
}
