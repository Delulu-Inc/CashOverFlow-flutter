/// An AI recommendation (`GET /explanation`).
class RecommendationItem {
  const RecommendationItem({
    required this.tag,
    required this.title,
    required this.points,
  });

  final String tag;
  final String title;
  final List<String> points;

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    List<String> readList(Object? value) =>
        value is List ? value.map((e) => e.toString()).toList() : const [];

    final points = json['points'] is List
        ? readList(json['points'])
        : json['bullets'] is List
        ? readList(json['bullets'])
        : readList(json['actions']);

    return RecommendationItem(
      tag:
          json['tag']?.toString() ??
          json['category']?.toString() ??
          '# Actionable Step',
      title:
          json['title']?.toString() ??
          json['action']?.toString() ??
          json['description']?.toString() ??
          '',
      points: points,
    );
  }

  /// Shown when the API is unreachable so the dashboard stays usable.
  static List<RecommendationItem> fallback(int horizonDays) {
    return [
      const RecommendationItem(
        tag: '# Delay non-essential Payments',
        title:
            'Consider delaying \$12K in non-essential payments until Oct 25. This will give you more flexibility over the next two weeks and help keep your projected cash balance above the minimum buffer.',
        points: [
          '+\$12K Cash preserved',
          '14 days Flexibility gained',
          '\$60K Target buffer',
        ],
      ),
      const RecommendationItem(
        tag: '# Review overdue invoices',
        title:
            'Review the \$20K in overdue invoices and follow up with customers who have missed their payment dates. Collecting these outstanding amounts could improve your available cash.',
        points: [
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
          '$horizonDays days Forecast period',
        ],
      ),
    ];
  }
}
