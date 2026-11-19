import 'package:flutter/painting.dart';

/// A risk flagged by the AI (`GET /risks`).
class RiskSignal {
  const RiskSignal({
    required this.riskType,
    required this.severity,
    required this.headline,
    required this.headlineAr,
  });

  final String riskType;
  final String severity;
  final String headline;
  final String headlineAr;

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

  /// Shown when the API is unreachable so the dashboard stays usable.
  static List<RiskSignal> fallback(int horizonDays) {
    return [
      const RiskSignal(
        riskType: 'Concentration',
        severity: 'high',
        headline: '37% of outstanding receivables sit with a single customer.',
        headlineAr: '',
      ),
      const RiskSignal(
        riskType: 'Overdue',
        severity: 'medium',
        headline: '18% of receivables are more than 60 days past due.',
        headlineAr: '',
      ),
      RiskSignal(
        riskType: 'Buffer',
        severity: 'low',
        headline:
            'Low 5% chance of falling below the minimum cash buffer over $horizonDays days.',
        headlineAr: '',
      ),
    ];
  }
}
