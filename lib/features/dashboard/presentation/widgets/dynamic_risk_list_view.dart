import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/risk_signal.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Risks flagged by the AI for the selected period (`GET /risks`).
class DynamicRiskListView extends StatefulWidget {
  const DynamicRiskListView({
    super.key,
    required this.days,
    this.asOf = '2026-09-01',
  });

  final int days;
  final String asOf;

  @override
  State<DynamicRiskListView> createState() => _DynamicRiskListViewState();
}

class _DynamicRiskListViewState extends State<DynamicRiskListView> {
  late Future<List<RiskSignal>> _risksFuture;

  @override
  void initState() {
    super.initState();
    _risksFuture = _fetch();
  }

  @override
  void didUpdateWidget(covariant DynamicRiskListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days || oldWidget.asOf != widget.asOf) {
      setState(() {
        _risksFuture = _fetch();
      });
    }
  }

  Future<List<RiskSignal>> _fetch() {
    return context.read<DashboardRepository>().fetchRiskSignals(
      asOf: widget.asOf,
      horizonDays: widget.days,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RiskSignal>>(
      future: _risksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final signals = snapshot.data ?? const <RiskSignal>[];

        if (signals.isEmpty) {
          return const Center(
            child: Text(
              'No risks identified for this period.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          );
        }

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

/// A single risk note with a severity colored edge.
class NoteItem extends StatelessWidget {
  const NoteItem({
    super.key,
    required this.text,
    required this.color,
    required this.severity,
  });

  final String text;
  final Color color;
  final String severity;

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
