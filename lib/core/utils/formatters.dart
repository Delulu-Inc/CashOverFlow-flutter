import 'package:intl/intl.dart';

/// Shared number & date formatting.
abstract final class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  /// `$1.2M`, `$350.5K`, `$420`.
  ///
  /// [thousandsDecimals] controls the precision of the `K` suffix (KPI cards
  /// use one decimal, chart axis labels use none).
  static String compactCurrency(double amount, {int thousandsDecimals = 1}) {
    if (amount.abs() >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(thousandsDecimals)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  /// `$1,234,568`.
  static String currency(num? amount) => _currency.format(amount ?? 0);

  /// `1 Sep 2026`.
  static String shortDate(DateTime date) =>
      DateFormat('d MMM yyyy', 'en_US').format(date);

  /// `1 Sep`.
  static String dayMonth(DateTime date) =>
      DateFormat('d MMM', 'en_US').format(date);

  /// `2026-09-01` – the format expected by the API `as_of` parameters.
  static String isoDate(DateTime date) =>
      DateFormat('yyyy-MM-dd', 'en_US').format(date);
}
