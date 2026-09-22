import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. Model Class
// ==========================================
class KpiData {
  final double cashOnHand;
  final double minCashBuffer;
  final double receivablesOutstanding;
  final double receivablesOverdue;
  final double payablesOutstanding;
  final double creditLineAvailable;

  KpiData({
    required this.cashOnHand,
    required this.minCashBuffer,
    required this.receivablesOutstanding,
    required this.receivablesOverdue,
    required this.payablesOutstanding,
    required this.creditLineAvailable,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble() ?? 0.0,
      minCashBuffer: (json['minCashBuffer'] as num?)?.toDouble() ?? 0.0,
      receivablesOutstanding:
          (json['receivablesOutstanding'] as num?)?.toDouble() ?? 0.0,
      receivablesOverdue:
          (json['receivablesOverdue'] as num?)?.toDouble() ?? 0.0,
      payablesOutstanding:
          (json['payablesOutstanding'] as num?)?.toDouble() ?? 0.0,
      creditLineAvailable:
          (json['creditLineAvailable'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

String formatCurrency(double amount) {
  if (amount.abs() >= 1000000) {
    return '\$${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount.abs() >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return '\$${amount.toStringAsFixed(0)}';
  }
}

// ==========================================
// 2. MetricCard Widget
// ==========================================
class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. Section Widget
// ==========================================
class KpiMetricsSection extends StatefulWidget {
  final int days;

  const KpiMetricsSection({
    super.key,
    this.days = 30,
  });

  @override
  State<KpiMetricsSection> createState() => _KpiMetricsSectionState();
}

class _KpiMetricsSectionState extends State<KpiMetricsSection> {
  late Future<KpiData> _kpiFuture;

  @override
  void initState() {
    super.initState();
    _kpiFuture = fetchKpis(widget.days);
  }

  @override
  void didUpdateWidget(covariant KpiMetricsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      setState(() {
        _kpiFuture = fetchKpis(widget.days);
      });
    }
  }

  Future<KpiData> fetchKpis(int horizonDays) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token') ?? prefs.getString('token');

    final url = Uri.parse(
      'https://cashoverflow-api.runasp.net/v1/kpis?companyId=DEMO&horizonDays=$horizonDays',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return KpiData.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load KPIs: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KpiData>(
      future: _kpiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'Error loading metrics: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;

        return Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Cash on hand',
                value: formatCurrency(data.cashOnHand),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Buffer',
                value: formatCurrency(data.minCashBuffer),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Owed to you',
                value: formatCurrency(data.receivablesOutstanding),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Overdue',
                value: formatCurrency(data.receivablesOverdue),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'You owe',
                value: formatCurrency(data.payablesOutstanding),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Facility',
                value: formatCurrency(data.creditLineAvailable),
              ),
            ),
          ],
        );
      },
    );
  }
}