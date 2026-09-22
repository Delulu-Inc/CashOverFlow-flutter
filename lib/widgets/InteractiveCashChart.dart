import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. Models
// ==========================================
class DailyForecast {
  final DateTime date;
  final double expectedCash;
  final double pessimisticCash;
  final double optimisticCash;
  final double netCashFlow;

  DailyForecast({
    required this.date,
    required this.expectedCash,
    required this.pessimisticCash,
    required this.optimisticCash,
    required this.netCashFlow,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date']),
      expectedCash: (json['expectedCash'] as num).toDouble(),
      pessimisticCash: (json['pessimisticCash'] as num).toDouble(),
      optimisticCash: (json['optimisticCash'] as num).toDouble(),
      netCashFlow: (json['netCashFlow'] as num).toDouble(),
    );
  }
}

class CashForecastData {
  final double startCashOnHand;
  final double minCashBuffer;
  final int horizonDays;
  final List<DailyForecast> dailyForecast;

  CashForecastData({
    required this.startCashOnHand,
    required this.minCashBuffer,
    required this.horizonDays,
    required this.dailyForecast,
  });

  factory CashForecastData.fromJson(Map<String, dynamic> json) {
    var list = json['dailyForecast'] as List;
    List<DailyForecast> forecasts = list
        .map((i) => DailyForecast.fromJson(i))
        .toList();

    return CashForecastData(
      startCashOnHand: (json['startCashOnHand'] as num).toDouble(),
      minCashBuffer: (json['minCashBuffer'] as num).toDouble(),
      horizonDays: json['horizonDays'] ?? 30,
      dailyForecast: forecasts,
    );
  }
}

// ==========================================
// 2. Interactive Chart Widget
// ==========================================
class InteractiveCashChart extends StatefulWidget {
  final int days;
  final Function(double startCash)? onDataLoaded;

  const InteractiveCashChart({
    super.key,
    this.days = 30,
    this.onDataLoaded,
  });

  @override
  State<InteractiveCashChart> createState() => _InteractiveCashChartState();
}

class _InteractiveCashChartState extends State<InteractiveCashChart> {
  late Future<CashForecastData> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = fetchCashForecast(widget.days);
  }

  @override
  void didUpdateWidget(covariant InteractiveCashChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      setState(() {
        _forecastFuture = fetchCashForecast(widget.days);
      });
    }
  }

  Future<CashForecastData> fetchCashForecast(int horizonDays) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token') ?? prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        'https://cashoverflow-api.runasp.net/v1/forecast?companyId=DEMO&horizonDays=$horizonDays',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final forecastData = CashForecastData.fromJson(jsonDecode(response.body));

      await prefs.setDouble('startCashOnHand', forecastData.startCashOnHand);

      if (widget.onDataLoaded != null) {
        widget.onDataLoaded!(forecastData.startCashOnHand);
      }

      return forecastData;
    } else {
      throw Exception('Failed to load forecast data (${response.statusCode})');
    }
  }

  String _formatShortCurrency(double value) {
    if (value.abs() >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

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
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.dailyForecast.isEmpty) {
          return const Center(child: Text('No forecast data available'));
        }

        final forecast = snapshot.data!;
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

          // Interpolate 50% band (p75 & p25) between median and extremes
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
        final double intervalY = ((maxY - minY) / 5).clamp(500000, 10000000);

        return Column(
          children: [
            // Top Legend
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildLegendItem(
                    color: const Color(0xFFBFDBFE).withOpacity(0.6),
                    label: '90% of futures (p05–p95)',
                    isSquare: true,
                  ),
                  const SizedBox(width: 14),
                  _buildLegendItem(
                    color: const Color(0xFF93C5FD).withOpacity(0.8),
                    label: '50% of futures (p25–p75)',
                    isSquare: true,
                  ),
                  const SizedBox(width: 14),
                  _buildLegendItem(
                    color: const Color(0xFF2563EB),
                    label: 'median (p50)',
                    isSquare: false,
                  ),
                ],
              ),
            ),

            // Fan Line Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: intervalY,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
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
                          int index = value.toInt();
                          if (index >= 0 && index < list.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${list[index].date.day} ${_getMonthAbbr(list[index].date.month)}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
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
                            _formatShortCurrency(value),
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
                      getTooltipItems: (touchedSpots) {
                        final primarySpot = touchedSpots.firstWhere(
                          (s) => s.barIndex == 4,
                          orElse: () => touchedSpots.first,
                        );
                        final itemDate = list[primarySpot.x.toInt()].date;
                        final dateStr =
                            '${itemDate.day} ${_getMonthAbbr(itemDate.month)} ${itemDate.year}';
                        final valStr = _formatShortCurrency(primarySpot.y);

                        return [
                          LineTooltipItem(
                            '$dateStr\nMedian (p50): $valStr',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                  lineBarsData: [
                    // 0: p95 (Top 90% boundary)
                    LineChartBarData(
                      spots: p95Spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.transparent,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                    ),
                    // 1: p05 (Bottom 90% boundary)
                    LineChartBarData(
                      spots: p05Spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.transparent,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                    ),
                    // 2: p75 (Top 50% boundary)
                    LineChartBarData(
                      spots: p75Spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.transparent,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                    ),
                    // 3: p25 (Bottom 50% boundary)
                    LineChartBarData(
                      spots: p25Spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.transparent,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                    ),
                    // 4: Solid Median Curve (p50)
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
                    // Outer 90% Confidence Interval
                    BetweenBarsData(
                      fromIndex: 0,
                      toIndex: 1,
                      color: const Color(0xFFDBEAFE).withOpacity(0.55),
                    ),
                    // Inner 50% Confidence Interval
                    BetweenBarsData(
                      fromIndex: 2,
                      toIndex: 3,
                      color: const Color(0xFFBFDBFE).withOpacity(0.70),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      // Red Dotted Cash Buffer Line
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
                              'Cash buffer: ${_formatShortCurrency(forecast.minCashBuffer)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        if (isSquare)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}