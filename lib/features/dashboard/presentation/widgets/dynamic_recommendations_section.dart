import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/dashboard_repository.dart';

/// AI recommendations for the selected period (`GET /explanation`).
///
/// Cards are laid out side by side on wide screens and stacked below 900px.
class DynamicRecommendationsSection extends StatefulWidget {
  const DynamicRecommendationsSection({
    super.key,
    required this.days,
    this.asOf = '2026-09-25',
    this.onOpenAiSupport,
  });

  final int days;
  final String asOf;
  final VoidCallback? onOpenAiSupport;

  @override
  State<DynamicRecommendationsSection> createState() =>
      _DynamicRecommendationsSectionState();
}

class _DynamicRecommendationsSectionState
    extends State<DynamicRecommendationsSection> {
  static const double _spacing = 16;

  late Future<List<RecommendationItem>> _recsFuture;

  @override
  void initState() {
    super.initState();
    _recsFuture = _fetch();
  }

  @override
  void didUpdateWidget(covariant DynamicRecommendationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days || oldWidget.asOf != widget.asOf) {
      setState(() {
        _recsFuture = _fetch();
      });
    }
  }

  Future<List<RecommendationItem>> _fetch() {
    return context.read<DashboardRepository>().fetchRecommendations(
      asOf: widget.asOf,
      horizonDays: widget.days,
    );
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

        final recs = snapshot.data ?? RecommendationItem.fallback(widget.days);
        final cards = [
          for (final rec in recs)
            RecommendationCard(
              tag: rec.tag,
              title: rec.title,
              points: rec.points,
              onDiscuss: widget.onOpenAiSupport,
            ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: _spacing),
                    cards[i],
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: _spacing),
                  Expanded(child: cards[i]),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

/// A single recommendation with its expected impact.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.tag,
    required this.title,
    required this.points,
    this.onDiscuss,
  });

  final String tag;
  final String title;
  final List<String> points;
  final VoidCallback? onDiscuss;

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
              color: AppColors.textPrimary,
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
                backgroundColor: AppColors.primary,
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
