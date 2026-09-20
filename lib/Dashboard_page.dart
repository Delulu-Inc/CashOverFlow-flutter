import 'package:cash_overflow/ai_support.dart';
import 'package:cash_overflow/widgets/DynamicRiskListView.dart';
import 'package:cash_overflow/widgets/InteractiveCashChart.dart';
import 'package:cash_overflow/widgets/KpiMetricsSection.dart';
import 'package:cash_overflow/widgets/Sidebar.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPeriod = 'Next 30 Days';

  // دالة لاستخراج عدد الأيام من النص
  int _getDaysFromPeriod(String period) {
    final RegExp regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(period);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 30;
  }

  // دالة لتنسيق التاريخ بالشكل المطلوب (مثال: 25 Oct 2026)
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final int days = _getDaysFromPeriod(selectedPeriod);

    // 🔴 التعديل هنا: حدد تاريخ البداية المعين في الجدول بدال DateTime.now()
    // يمكنك تغييره للـ DateTime المطلوب أو جلب أول تاريخ من القائمة
    final DateTime startDate = DateTime(
      2026,
      9,
      25,
    ); // مثال: بداية من 25 سبتمبر 2026
    final DateTime endDate = startDate.add(Duration(days: days));

    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar
          const SidebarWidget(currentRoute: 'Dashboard'),

          // 2. Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header & Period Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cash Flow Analysis',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your company's cash position, what the AI has flagged, and what it recommends doing about it.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // Time Filter Toggles
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            _buildPeriodButton('Next 30 Days'),
                            _buildPeriodButton('Next 60 Days'),
                            _buildPeriodButton('Next 90 Days'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Metric Cards Row
                  const KpiMetricsSection(),

                  const SizedBox(height: 24),

                  // Middle Section: Chart & Notes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart Container
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 420,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cash over the ${selectedPeriod.toLowerCase()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  // التكست المعروض هنا هيتغير تلقائي بناءً على startDate المحدد و selectedPeriod
                                  Text(
                                    '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Expanded(child: InteractiveCashChart(days: days)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Notes Container
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 420,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(child: DynamicRiskListView(days: days)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recommendations Section
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RecommendationCard(
                          tag: '# Delay non-essential Payments',
                          title:
                              r'Consider delaying $12K in non-essential payments until Oct 25. This will give you more flexibility over the next two weeks and help keep your projected cash balance above the minimum buffer.',
                          points: [
                            r'+$12K Cash preserved',
                            '14 days Flexibility gained',
                            r'$60K Target buffer',
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: RecommendationCard(
                          tag: '# Review overdue invoices',
                          title:
                              r'Review the $20K in overdue invoices and follow up with customers who have missed their payment dates. Collecting these outstanding amounts could improve your available cash and reduce pressure on your upcoming expenses.',
                          points: [
                            r'+$20K Potential cash recovered',
                            '5 invoices Currently overdue',
                            '7 days Suggested follow-up window',
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: RecommendationCard(
                          tag: '# Maintain your cash buffer',
                          title:
                              r'Your projected cash balance is expected to approach the $60K minimum buffer later this month. Consider monitoring upcoming expenses and prioritizing essential payments to maintain a safer cash position.',
                          points: [
                            r'$60K Minimum target buffer',
                            r'$18K Projected shortfall risk',
                            '30 days Forecast period',
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String title) {
    final bool isSelected = selectedPeriod == title;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => selectedPeriod = title),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF1E293B) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== METRIC CARD ====================
class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({super.key, required this.title, required this.value});

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

// ==================== RECOMMENDATION CARD ====================
class RecommendationCard extends StatelessWidget {
  final String tag;
  final String title;
  final List<String> points;

  const RecommendationCard({
    super.key,
    required this.tag,
    required this.title,
    required this.points,
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
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
