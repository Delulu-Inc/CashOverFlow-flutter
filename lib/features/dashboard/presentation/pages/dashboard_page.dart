import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../widgets/dynamic_recommendations_section.dart';
import '../widgets/dynamic_risk_list_view.dart';
import '../widgets/interactive_cash_chart.dart';
import '../widgets/kpi_metrics_section.dart';

/// Cash-flow analysis: KPIs, forecast fan chart, risks and recommendations.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.onOpenAiSupport});

  final VoidCallback? onOpenAiSupport;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const List<int> _periods = [30, 60, 90];

  /// Below this content width the chart and the notes are stacked.
  static const double _stackedBelow = 900;

  int _days = 30;

  String _periodLabel(int days) => 'Next $days Days';

  @override
  Widget build(BuildContext context) {
    final DateTime startDate = AppConfig.demoAsOfDate;
    final DateTime endDate = startDate.add(Duration(days: _days));
    final String asOfParam = Formatters.isoDate(startDate);
    final bool isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool stacked = constraints.maxWidth < _stackedBelow;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // HEADER
                // =====================================================
                _buildHeader(compact: constraints.maxWidth < 760),

                const SizedBox(height: 24),

                // =====================================================
                // KPI METRICS
                // =====================================================
                KpiMetricsSection(days: _days),

                const SizedBox(height: 24),

                // =====================================================
                // CHART + NOTES
                // =====================================================
                if (stacked) ...[
                  SizedBox(
                    height: isMobile ? 400 : 460,
                    child: _buildChartCard(startDate, endDate),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 460,
                    child: _buildNotesCard(asOfParam, fullWidth: true),
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 460,
                          child: _buildChartCard(startDate, endDate),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 460,
                          child: _buildNotesCard(asOfParam),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // =====================================================
                // RECOMMENDATIONS
                // =====================================================
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                DynamicRecommendationsSection(
                  days: _days,
                  asOf: asOfParam,
                  onOpenAiSupport: widget.onOpenAiSupport,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({required bool compact}) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash Flow Analysis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Your company's cash position, what the AI has flagged, and what it recommends doing about it.",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 16),
          _buildPeriodSelector(expand: true),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildPeriodSelector({bool expand = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final days in _periods)
            if (expand)
              Expanded(child: _buildPeriodButton(days, compact: true))
            else
              _buildPeriodButton(days),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(int days, {bool compact = false}) {
    final bool isSelected = _days == days;

    return Semantics(
      button: true,
      selected: isSelected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _days = days),
          child: Container(
            alignment: compact ? Alignment.center : null,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              _periodLabel(days),
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(DateTime startDate, DateTime endDate) {
    final title = Text(
      'Cash over the ${_periodLabel(_days).toLowerCase()}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
    final range = Text(
      '${Formatters.shortDate(startDate)} - ${Formatters.shortDate(endDate)}',
      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 4), range],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: title),
                  const SizedBox(width: 12),
                  range,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: InteractiveCashChart(days: _days)),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String asOfParam, {bool fullWidth = false}) {
    final String chance = _days == 90
        ? '5.4%'
        : (_days == 60 ? '3.8%' : '1.2%');

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
          Container(
            width: fullWidth ? double.infinity : null,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.appBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chance of falling below the cash buffer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      chance,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Low',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Runway beyond $_days days',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Overall: Medium',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Risks fetched from /v1/risks
          Expanded(
            child: DynamicRiskListView(days: _days, asOf: asOfParam),
          ),
        ],
      ),
    );
  }
}
