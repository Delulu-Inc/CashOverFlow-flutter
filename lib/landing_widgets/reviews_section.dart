import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF03050B),
      padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                width: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/tom.jpg'),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage('assets/images/emily.jpg'),
                      ),
                    ),
                    Positioned(
                      left: 68,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/bradly.jpg'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'What our clients say',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFCFCFC),
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const SizedBox(
                width: 1155,
                child: Text(
                  'Behind every number is a decision. Here’s how clearer cash-flow insights can help teams plan ahead, act earlier, and feel more confident about what comes next.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 28,
                    height: 1.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 54),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        _TestimonialCard(
                          avatarPath: 'assets/images/sarah.jpg',
                          name: 'Sarah Mitchell',
                          role: 'CFO · Retail Company',
                          comment:
                              'Cash Overflow helped us see a potential liquidity gap weeks before it became a problem. Instead of waiting until the pressure was already there, we could understand what was causing the gap and plan ahead. The forecast gave our finance team a much clearer picture of what was coming next.',
                        ),
                        SizedBox(height: 24),
                        _TestimonialCard(
                          avatarPath: 'assets/images/tom.jpg',
                          name: 'Tom David',
                          role: 'Founder · Retail',
                          comment:
                              'Cash Overflow turns financial data into decisions we can actually act on. It makes planning around delayed payments much easier.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: const [
                        _TestimonialCard(
                          avatarPath: 'assets/images/michael.jpg',
                          name: 'Michael Anderson',
                          role: 'COO · Manufacturing',
                          comment:
                              'We used to react to cash-flow issues when they were already in front of us. Having an early warning gives our team time to prepare and take action before a potential shortage becomes critical. It has changed the way we think about cash-flow planning, from reacting to problems to preparing for them in advance.',
                        ),
                        SizedBox(height: 24),
                        _TestimonialCard(
                          avatarPath: 'assets/images/emily.jpg',
                          name: 'Emily Carter',
                          role: 'Finance Manager · SaaS',
                          comment:
                              'The what-if simulations are incredibly useful for our planning process. We can test different payment scenarios and see how each one could affect our future cash position before making a decision. It gives us the ability to explore different options instead of relying on assumptions when dealing with uncertain cash flow.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: const [
                        _TestimonialCard(
                          avatarPath: 'assets/images/david.jpg',
                          name: 'David Chen',
                          role: 'Founder · E-commerce',
                          comment:
                              'We used to spend hours going through spreadsheets just to understand what was affecting our cash position. Cash Overflow makes that process much easier by turning complex financial data into clear insights. Being able to quickly see upcoming risks and the factors behind them helps us make decisions with much more confidence.',
                        ),
                        SizedBox(height: 24),
                        _TestimonialCard(
                          avatarPath: 'assets/images/bradly.jpg',
                          name: 'Bradly Williams',
                          role: 'Finance Director · Logistics',
                          comment:
                              'The biggest value is clarity. We can see where our cash is heading and understand which upcoming payments could put pressure on it.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HOVERABLE TESTIMONIAL CARD WIDGET
// -----------------------------------------------------------------------------

class _TestimonialCard extends StatefulWidget {
  final String avatarPath;
  final String name;
  final String role;
  final String comment;

  const _TestimonialCard({
    required this.avatarPath,
    required this.name,
    required this.role,
    required this.comment,
  });

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        width: double.infinity,
        //height: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFD9D9D9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.avatarPath),
            ),
            const SizedBox(height: 12),
            Text(
              widget.name,
              style: const TextStyle(
                color: Color(0xFF050505),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.role,
              style: const TextStyle(
                color: Color(0xFF808080),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              widget.comment,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
