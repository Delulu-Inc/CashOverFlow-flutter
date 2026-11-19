import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/responsive/responsive.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static const List<_FooterLinkColumn> _linkColumns = [
    _FooterLinkColumn(title: 'Quick Links', links: ['Home', 'Subscription']),
    _FooterLinkColumn(
      title: 'Contact',
      links: [
        '123 , Cairo, Egypt',
        '+20 100 123 4567',
        'hello@Cash_Overflow.com',
      ],
    ),
    _FooterLinkColumn(title: 'Help', links: ['FAQ', 'Help Center', 'Support']),
  ];

  /// Tablets & phones: description, links and bottom bar stacked.
  Widget _buildCompact(BuildContext context) {
    final double width = context.screenWidth;
    final bool isMobile = width < Breakpoints.mobile;
    final double gutter = Responsive.landingGutter(width);

    const TextStyle bottomStyle = TextStyle(
      color: Color(0xFFFCFCFC),
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFF03050B),
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: isMobile ? 48 : 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'See what’s happening with your cash today, understand what’s coming next, and stay one step ahead of potential cash-flow gaps.',
            style: TextStyle(
              color: const Color(0xFFB3B3B3),
              fontSize: isMobile ? 16 : 18,
              height: 1.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Follow US',
            style: TextStyle(
              color: Color(0xFFFCFCFC),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _SocialIcon(iconPath: 'assets/icons/logos_facebook.svg'),
              SizedBox(width: 30),
              _SocialIcon(iconPath: 'assets/icons/instagram.svg'),
              SizedBox(width: 30),
              _SocialIcon(iconPath: 'assets/icons/tiktok.svg'),
            ],
          ),
          const SizedBox(height: 40),
          const Wrap(spacing: 56, runSpacing: 24, children: _linkColumns),
          const SizedBox(height: 40),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                Text(
                  '© 2026 Cash OverFlow. All Rights Reserved',
                  style: bottomStyle,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Privacy', style: bottomStyle),
                    SizedBox(width: 24),
                    Text(
                      'Terms & Condition',
                      style: TextStyle(
                        color: Color(0xFFC0C0C0),
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.screenWidth < Breakpoints.desktop) {
      return _buildCompact(context);
    }

    // Desktop: original Figma layout.
    return Container(
      color: const Color(0xFF03050B),
      padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Column
                const Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'See what’s happening with your cash today,\nunderstand what’s coming next, and stay one\nstep ahead of potential cash-flow gaps.',
                        style: TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 18,
                          height: 1.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Follow US',
                        style: TextStyle(
                          color: Color(0xFFFCFCFC),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _SocialIcon(
                            iconPath: 'assets/icons/logos_facebook.svg',
                          ),
                          SizedBox(width: 30),
                          _SocialIcon(iconPath: 'assets/icons/instagram.svg'),
                          SizedBox(width: 30),
                          _SocialIcon(iconPath: 'assets/icons/tiktok.svg'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 160),

                // Keeps the 4:3 split of the design, but the links never
                // overflow when their text is wider than the 3/7 share.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: (constraints.maxWidth - 160) * 3 / 7,
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _FooterLinkColumn(
                          title: 'Quick Links',
                          links: ['Home', 'Subscription'],
                        ),
                        SizedBox(width: 56),
                        _FooterLinkColumn(
                          title: 'Contact',
                          links: [
                            '123 , Cairo, Egypt',
                            '+20 100 123 4567',
                            'hello@Cash_Overflow.com',
                          ],
                        ),
                        SizedBox(width: 56),
                        _FooterLinkColumn(
                          title: 'Help',
                          links: ['FAQ', 'Help Center', 'Support'],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 64),

          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),

          const SizedBox(height: 24),

          // Bottom Bar
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Cash OverFlow. All Rights Reserved',
                style: TextStyle(
                  color: Color(0xFFFCFCFC),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy',
                    style: TextStyle(
                      color: Color(0xFFFCFCFC),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 24),
                  Text(
                    'Terms & Condition',
                    style: TextStyle(
                      color: Color(0xFFC0C0C0),
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------

// HELPER WIDGETS FOR FOOTER

// -----------------------------------------------------------------------------

class _FooterLinkColumn extends StatelessWidget {
  final String title;

  final List<String> links;

  const _FooterLinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFCFCFC),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {},
              child: Text(
                link,
                style: const TextStyle(
                  color: Color(0xFFB3B3B3),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String iconPath;

  const _SocialIcon({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: SvgPicture.asset(iconPath, width: 32, height: 32),
    );
  }
}
