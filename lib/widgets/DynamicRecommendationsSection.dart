import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationItem {
  final String tag;
  final String title;
  final List<String> points;

  RecommendationItem({
    required this.tag,
    required this.title,
    required this.points,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    List<String> parsedPoints = [];
    if (json['points'] is List) {
      parsedPoints = (json['points'] as List).map((e) => e.toString()).toList();
    } else if (json['bullets'] is List) {
      parsedPoints = (json['bullets'] as List).map((e) => e.toString()).toList();
    } else if (json['actions'] is List) {
      parsedPoints = (json['actions'] as List).map((e) => e.toString()).toList();
    }

    return RecommendationItem(
      tag: json['tag']?.toString() ??
          json['category']?.toString() ??
          '# Actionable Step',
      title: json['title']?.toString() ??
          json['action']?.toString() ??
          json['description']?.toString() ??
          '',
      points: parsedPoints,
    );
  }
}

class DynamicRecommendationsSection extends StatefulWidget {
  final int days;
  final String asOf;
  final VoidCallback? onOpenAiSupport;

  const DynamicRecommendationsSection({
    super.key,
    required this.days,
    this.asOf = '2026-09-25',
    this.onOpenAiSupport,
  });

  @override
  State<DynamicRecommendationsSection> createState() =>
      _DynamicRecommendationsSectionState();
}

class _DynamicRecommendationsSectionState
    extends State<DynamicRecommendationsSection> {
  late Future<List<RecommendationItem>> _recsFuture;

  @override
  void initState() {
    super.initState();
    _recsFuture = _fetchRecommendations();
  }

  @override
  void didUpdateWidget(covariant DynamicRecommendationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days || oldWidget.asOf != widget.asOf) {
      setState(() {
        _recsFuture = _fetchRecommendations();
      });
    }
  }

  Future<List<RecommendationItem>> _fetchRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? prefs.getString('token');

    final uri = Uri.parse(
      'https://cashoverflow-api.runasp.net/v1/explanation?as_of=${widget.asOf}&horizon=${widget.days}&language=en&stress_buffer=false',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> items = [];

        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final nested = decoded['recommendations'] ??
              decoded['actions'] ??
              decoded['items'] ??
              decoded['explanations'];
          if (nested is List) {
            items = nested;
          } else if (decoded['narrative'] != null || decoded['summary'] != null) {
            return [
              RecommendationItem(
                tag: '# Liquidity Overview',
                title: decoded['summary']?.toString() ??
                    decoded['narrative']?.toString() ??
                    'Review operating cash balance for the upcoming period.',
                points: [
                  'Horizon: ${widget.days} days',
                  'Buffer: Target maintained',
                  'Confidence: High',
                ],
              )
            ];
          }
        }

        if (items.isNotEmpty) {
          return items
              .whereType<Map<String, dynamic>>()
              .map((e) => RecommendationItem.fromJson(e))
              .toList();
        }
      }

      return _getFallbackRecommendations();
    } catch (_) {
      return _getFallbackRecommendations();
    }
  }

  List<RecommendationItem> _getFallbackRecommendations() {
    return [
      RecommendationItem(
        tag: '# Delay non-essential Payments',
        title:
            'Consider delaying \$12K in non-essential payments until Oct 25. This will give you more flexibility over the next two weeks and help keep your projected cash balance above the minimum buffer.',
        points: const [
          '+\$12K Cash preserved',
          '14 days Flexibility gained',
          '\$60K Target buffer',
        ],
      ),
      RecommendationItem(
        tag: '# Review overdue invoices',
        title:
            'Review the \$20K in overdue invoices and follow up with customers who have missed their payment dates. Collecting these outstanding amounts could improve your available cash.',
        points: const [
          '+\$20K Potential cash recovered',
          '5 invoices Currently overdue',
          '7 days Suggested follow-up window',
        ],
      ),
      RecommendationItem(
        tag: '# Maintain your cash buffer',
        title:
            'Your projected cash balance approaches the minimum buffer threshold. Prioritize essential commitments and monitor incoming receivables to avoid cash crunches.',
        points: [
          '\$60K Minimum target buffer',
          '\$18K Projected shortfall risk',
          '${widget.days} days Forecast period',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecommendationItem>>(
      future: _recsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final recs = snapshot.data ?? _getFallbackRecommendations();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recs.map((rec) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: RecommendationCard(
                  tag: rec.tag,
                  title: rec.title,
                  points: rec.points,
                  onDiscuss: widget.onOpenAiSupport,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ================================================================
// RECOMMENDATION CARD (Self-contained)
// ================================================================
class RecommendationCard extends StatelessWidget {
  final String tag;
  final String title;
  final List<String> points;
  final VoidCallback? onDiscuss;

  const RecommendationCard({
    super.key,
    required this.tag,
    required this.title,
    required this.points,
    this.onDiscuss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDiscuss,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.public, size: 16),
              label: const Text(
                'Discuss with AI',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}