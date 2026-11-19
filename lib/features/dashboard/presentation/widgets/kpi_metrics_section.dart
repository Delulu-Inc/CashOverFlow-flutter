import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/kpi_data.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Single KPI tile.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of KPI tiles (`GET /kpis`), tied to the selected forecast period.
///
/// Six tiles side by side on desktop, a 3 or 2 column grid on smaller
/// screens.
class KpiMetricsSection extends StatefulWidget {
  const KpiMetricsSection({super.key, this.days = 30});

  final int days;

  @override
  State<KpiMetricsSection> createState() => _KpiMetricsSectionState();
}

class _KpiMetricsSectionState extends State<KpiMetricsSection> {
  static const double _spacing = 16;

  late Future<KpiData> _kpiFuture;

  @override
  void initState() {
    super.initState();
    _kpiFuture = _fetch();
  }

  @override
  void didUpdateWidget(covariant KpiMetricsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      setState(() {
        _kpiFuture = _fetch();
      });
    }
  }

  Future<KpiData> _fetch() =>
      context.read<DashboardRepository>().fetchKpis(widget.days);

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
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final cards = [
          MetricCard(
            title: 'Cash on hand',
            value: Formatters.compactCurrency(data.cashOnHand),
          ),
          MetricCard(
            title: 'Buffer',
            value: Formatters.compactCurrency(data.minCashBuffer),
          ),
          MetricCard(
            title: 'Owed to you',
            value: Formatters.compactCurrency(data.receivablesOutstanding),
          ),
          MetricCard(
            title: 'Overdue',
            value: Formatters.compactCurrency(data.receivablesOverdue),
          ),
          MetricCard(
            title: 'You owe',
            value: Formatters.compactCurrency(data.payablesOutstanding),
          ),
          MetricCard(
            title: 'Facility',
            value: Formatters.compactCurrency(data.creditLineAvailable),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int columns = width >= 900 ? 6 : (width >= 520 ? 3 : 2);

            if (columns == cards.length) {
              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: _spacing),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }

            final double cardWidth =
                (width - _spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: _spacing,
              runSpacing: _spacing,
              children: [
                for (final card in cards)
                  SizedBox(width: cardWidth, child: card),
              ],
            );
          },
        );
      },
    );
  }
}
