import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. Models
// ==========================================
class RiskSignal {
  final String riskType;
  final String severity;
  final String headline;
  final String headlineAr;

  RiskSignal({
    required this.riskType,
    required this.severity,
    required this.headline,
    required this.headlineAr,
  });

  factory RiskSignal.fromJson(Map<String, dynamic> json) {
    return RiskSignal(
      riskType: json['risk_type']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'low',
      headline: json['headline']?.toString() ?? '',
      headlineAr: json['headline_ar']?.toString() ?? '',
    );
  }

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return const Color(0xFFEF4444);
      case 'medium':
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }
}

// ==========================================
// 2. Dynamic Risk List Widget
// ==========================================
class DynamicRiskListView extends StatefulWidget {
  final int days;
  final String asOf;

  const DynamicRiskListView({
    super.key,
    required this.days,
    this.asOf = '2026-09-01',
  });

  @override
  State<DynamicRiskListView> createState() => _DynamicRiskListViewState();
}

class _DynamicRiskListViewState extends State<DynamicRiskListView> {
  late Future<List<RiskSignal>> _risksFuture;

  @override
  void initState() {
    super.initState();
    _risksFuture = fetchRiskSignals(widget.days);
  }

  @override
  void didUpdateWidget(covariant DynamicRiskListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days || oldWidget.asOf != widget.asOf) {
      setState(() {
        _risksFuture = fetchRiskSignals(widget.days);
      });
    }
  }

  Future<List<RiskSignal>> fetchRiskSignals(int horizonDays) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token') ?? prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        'https://cashoverflow-api.runasp.net/v1/risks?as_of=${widget.asOf}&horizon=$horizonDays&stress_buffer=false',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> signalsJson = data['signals'] ?? [];
      return signalsJson.map((json) => RiskSignal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load risk signals (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RiskSignal>>(
      future: _risksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No risks identified for this period.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          );
        }

        final signals = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: signals.length,
          itemBuilder: (context, index) {
            final signal = signals[index];
            return NoteItem(
              text: signal.headline,
              color: signal.severityColor,
              severity: signal.severity,
            );
          },
        );
      },
    );
  }
}

class NoteItem extends StatelessWidget {
  final String text;
  final Color color;
  final String severity;

  const NoteItem({
    super.key,
    required this.text,
    required this.color,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            severity.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}