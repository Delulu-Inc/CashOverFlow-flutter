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
      riskType: json['risk_type'] ?? '',
      severity: json['severity'] ?? 'low',
      headline: json['headline'] ?? '',
      headlineAr: json['headline_ar'] ?? '',
    );
  }

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}

// ==========================================
// 2. Dynamic Risk List Widget
// ==========================================
class DynamicRiskListView extends StatefulWidget {
  const DynamicRiskListView({super.key, required this.days});
  final int days;

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

  // تحديث الـ Future فور استلام قيمة جديدة لـ days من الويدجيت الأب
  @override
  void didUpdateWidget(covariant DynamicRiskListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      setState(() {
        _risksFuture = fetchRiskSignals(widget.days);
      });
    }
  }

  Future<List<RiskSignal>> fetchRiskSignals(int horizonDays) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse(
        'https://cashoverflow-api.runasp.net/v1/risks?as_of=2026-09-01&horizon=$horizonDays&stress_buffer=false',
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
    return Expanded(
      child: FutureBuilder<List<RiskSignal>>(
        future: _risksFuture,
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No risks identified'));
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
              );
            },
          );
        },
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  final String text;
  final Color color;

  const NoteItem({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
