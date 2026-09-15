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
  // إضافة Callback لتمرير القيمة للشاشة الأب فور وصولها من الـ API
  final Function(double startCash)? onDataLoaded;

  const InteractiveCashChart({super.key, this.days = 30, this.onDataLoaded});

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
    final String? token = prefs.getString('auth_token');

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

      // 1. حفظ القيمة في SharedPreferences لاستخدامها لاحقاً في أي مكان بالترتيب المحلي
      await prefs.setDouble('startCashOnHand', forecastData.startCashOnHand);

      // 2. إرسال القيمة عبر الـ Callback للشاشة الحالية إذا تم تمرير الدالة
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
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.dailyForecast.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('No forecast data available')),
          );
        }

        final forecast = snapshot.data!;
        final list = forecast.dailyForecast;

        final List<FlSpot> expectedSpots = [];
        final List<FlSpot> optimisticSpots = [];

        double maxY = 0;
        double minY = list.first.pessimisticCash;

        for (int i = 0; i < list.length; i++) {
          final item = list[i];
          expectedSpots.add(FlSpot(i.toDouble(), item.expectedCash));
          optimisticSpots.add(FlSpot(i.toDouble(), item.optimisticCash));

          if (item.optimisticCash > maxY) maxY = item.optimisticCash;
          if (item.pessimisticCash < minY) minY = item.pessimisticCash;
        }

        maxY = maxY * 1.1;
        minY = (minY * 0.9).clamp(0, double.infinity);
        final double intervalY = ((maxY - minY) / 5).clamp(1000000, 10000000);

        return SizedBox(
          height: 320,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: intervalY,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 1),
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
                    interval: (list.length / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < list.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${list[index].date.day} ${list[index].date.month}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
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
                        style: const TextStyle(
                          color: Colors.grey,
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
                touchSpotThreshold: 50,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E293B),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final itemDate = list[spot.x.toInt()].date;
                      final dateStr =
                          '${itemDate.day} ${itemDate.month} ${itemDate.year}';
                      final valStr = _formatShortCurrency(spot.y);

                      final label = spot.barIndex == 0
                          ? 'Optimistic'
                          : 'Expected';

                      return LineTooltipItem(
                        '$dateStr\n$label: $valStr',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((index) {
                        return TouchedSpotIndicatorData(
                          const FlLine(
                            color: Colors.blueAccent,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                          ),
                        );
                      }).toList();
                    },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: optimisticSpots,
                  isCurved: true,
                  color: Colors.blue.withOpacity(0.3),
                  barWidth: 1,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.05),
                  ),
                ),
                LineChartBarData(
                  spots: expectedSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
