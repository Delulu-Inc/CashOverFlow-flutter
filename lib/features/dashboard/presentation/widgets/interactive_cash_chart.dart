import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/models/cash_forecast.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Confidence fan chart of the cash forecast (`GET /forecast`).
///
/// * outer band: 90% of simulated futures (p05–p95)
/// * inner band: 50% of simulated futures (p25–p75)
/// * line: median (p50)
/// * dashed red line: minimum cash buffer
class InteractiveCashChart extends StatefulWidget {
  const InteractiveCashChart({super.key, this.days = 30, this.onDataLoaded});

  final int days;
  final ValueChanged<double>? onDataLoaded;

  @override
  State<InteractiveCashChart> createState() => _InteractiveCashChartState();
}

class _InteractiveCashChartState extends State<InteractiveCashChart> {
  static const int _medianBarIndex = 4;

  late Future<CashForecastData> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = _fetch();
  }

  @override
  void didUpdateWidget(covariant InteractiveCashChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      setState(() {
        _forecastFuture = _fetch();
      });
    }
  }

  Future<CashForecastData> _fetch() async {
    final data = await context.read<DashboardRepository>().fetchForecast(
      widget.days,
    );
    widget.onDataLoaded?.call(data.startCashOnHand);
    return data;
  }

  String _axisCurrency(double value) =>
      Formatters.compactCurrency(value, thousandsDecimals: 0);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CashForecastData>(
      future: _forecastFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.dailyForecast.isEmpty) {
          return const Center(child: Text('No forecast data available'));
        }

        return _buildChart(snapshot.data!);
      },
    );
  }

  Widget _buildChart(CashForecastData forecast) {
    final list = forecast.dailyForecast;

    final List<FlSpot> p95Spots = [];
    final List<FlSpot> p75Spots = [];
    final List<FlSpot> p50Spots = [];
    final List<FlSpot> p25Spots = [];
    final List<FlSpot> p05Spots = [];

    double maxY = 0;
    double minY = list.first.pessimisticCash;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      final double x = i.toDouble();

      final double p50 = item.expectedCash;
      final double p95 = item.optimisticCash;
      final double p05 = item.pessimisticCash;

      // Interpolate the 50% band (p75 & p25) between median and extremes.
      final double p75 = p50 + (p95 - p50) * 0.5;
      final double p25 = p50 - (p50 - p05) * 0.5;

      p95Spots.add(FlSpot(x, p95));
      p75Spots.add(FlSpot(x, p75));
      p50Spots.add(FlSpot(x, p50));
      p25Spots.add(FlSpot(x, p25));
      p05Spots.add(FlSpot(x, p05));

      if (p95 > maxY) maxY = p95;
      if (p05 < minY) minY = p05;
    }

    if (forecast.minCashBuffer < minY) {
      minY = forecast.minCashBuffer;
    }

    maxY = maxY * 1.08;
    minY = (minY * 0.88).clamp(0, double.infinity);
    if (maxY <= minY) maxY = minY + 1;
    final double intervalY = ((maxY - minY) / 5).clamp(500000, 10000000);

    LineChartBarData band(List<FlSpot> spots) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.2,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
      );
    }

    return Column(
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 14,
              runSpacing: 6,
              children: [
                _buildLegendItem(
                  color: const Color(0xFFBFDBFE).withValues(alpha: 0.6),
                  label: '90% of futures (p05–p95)',
                  isSquare: true,
                ),
                _buildLegendItem(
                  color: const Color(0xFF93C5FD).withValues(alpha: 0.8),
                  label: '50% of futures (p25–p75)',
                  isSquare: true,
                ),
                _buildLegendItem(
                  color: const Color(0xFF2563EB),
                  label: 'median (p50)',
                  isSquare: false,
                ),
              ],
            ),
          ),
        ),

        // Fan chart
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: intervalY,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: (list.length / 5).clamp(1, 30).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= list.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          Formatters.dayMonth(list[index].date),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: intervalY,
                    reservedSize: 55,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _axisCurrency(value),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (list.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchSpotThreshold: 30,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF0F172A),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) {
                    if (touchedSpots.isEmpty) return const [];
                    final primarySpot = touchedSpots.firstWhere(
                      (spot) => spot.barIndex == _medianBarIndex,
                      orElse: () => touchedSpots.first,
                    );
                    final index = primarySpot.x.toInt().clamp(
                      0,
                      list.length - 1,
                    );
                    final label =
                        '${Formatters.shortDate(list[index].date)}\n'
                        'Median (p50): ${_axisCurrency(primarySpot.y)}';

                    // fl_chart expects exactly one entry per touched spot:
                    // only the median gets a tooltip.
                    return [
                      for (final spot in touchedSpots)
                        identical(spot, primarySpot)
                            ? LineTooltipItem(
                                label,
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                    ];
                  },
                ),
              ),
              lineBarsData: [
                band(p95Spots), // 0: p95 (top of the 90% band)
                band(p05Spots), // 1: p05 (bottom of the 90% band)
                band(p75Spots), // 2: p75 (top of the 50% band)
                band(p25Spots), // 3: p25 (bottom of the 50% band)
                // 4: median (p50)
                LineChartBarData(
                  spots: p50Spots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: const Color(0xFF2563EB),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
              betweenBarsData: [
                BetweenBarsData(
                  fromIndex: 0,
                  toIndex: 1,
                  color: const Color(0xFFDBEAFE).withValues(alpha: 0.55),
                ),
                BetweenBarsData(
                  fromIndex: 2,
                  toIndex: 3,
                  color: const Color(0xFFBFDBFE).withValues(alpha: 0.70),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: forecast.minCashBuffer,
                    color: const Color(0xFFEF4444),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) =>
                          'Cash buffer: ${_axisCurrency(forecast.minCashBuffer)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isSquare,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSquare ? 12 : 14,
          height: isSquare ? 12 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
