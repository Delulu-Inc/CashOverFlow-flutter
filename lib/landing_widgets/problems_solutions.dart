import 'package:flutter/material.dart';

class ProblemSolutionSection extends StatefulWidget {
  const ProblemSolutionSection({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<ProblemSolutionSection> createState() => _ProblemSolutionSectionState();
}

class _ProblemSolutionSectionState extends State<ProblemSolutionSection> {
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _captionKey = GlobalKey();

  double _revealedHeight = 0;
  double _totalHeight = 1;

  double? _gapTop;
  double? _gapBottom;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateLineProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLineProgress());
  }

  @override
  void didUpdateWidget(covariant ProblemSolutionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_updateLineProgress);
      widget.scrollController.addListener(_updateLineProgress);
    }
  }

  void _updateLineProgress() {
    final box = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !mounted) return;

    final topOfSectionOnScreen = box.localToGlobal(Offset.zero).dy;
    final viewportHeight = MediaQuery.of(context).size.height;
    final totalHeight = box.size.height;

    final revealed =
        (viewportHeight * 0.75 - topOfSectionOnScreen).clamp(0.0, totalHeight);

    double? gapTop = _gapTop;
    double? gapBottom = _gapBottom;
    final captionBox =
        _captionKey.currentContext?.findRenderObject() as RenderBox?;
    if (captionBox != null && captionBox.attached) {
      final pos = captionBox.localToGlobal(Offset.zero, ancestor: box);
      gapTop = pos.dy - 14;
      gapBottom = pos.dy + captionBox.size.height + 14;
    }

    setState(() {
      _totalHeight = totalHeight;
      _revealedHeight = revealed;
      _gapTop = gapTop;
      _gapBottom = gapBottom;
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateLineProgress);
    super.dispose();
  }

  List<Widget> _buildLineSegments() {
    final gapTop = _gapTop;
    final gapBottom = _gapBottom;

    Widget segment(
        {required double top,
        required double height,
        required double revealedInSegment}) {
      return Positioned(
        top: top,
        left: 0,
        right: 0,
        height: height,
        child: Stack(
          children: [
            Center(
                child:
                    Container(width: 2, height: height, color: Colors.white24)),
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 2,
                height: revealedInSegment,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (gapTop == null || gapBottom == null) {
      return [
        segment(
            top: 0, height: _totalHeight, revealedInSegment: _revealedHeight)
      ];
    }

    final seg1Height = gapTop.clamp(0.0, _totalHeight);
    final seg2Top = gapBottom.clamp(0.0, _totalHeight);
    final seg2Height = (_totalHeight - seg2Top).clamp(0.0, _totalHeight);
    final seg1Revealed = _revealedHeight.clamp(0.0, seg1Height);
    final seg2Revealed = (_revealedHeight - seg2Top).clamp(0.0, seg2Height);

    return [
      segment(top: 0, height: seg1Height, revealedInSegment: seg1Revealed),
      segment(
          top: seg2Top, height: seg2Height, revealedInSegment: seg2Revealed),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 70),
      child: Stack(
        key: _contentKey,
        children: [
          ..._buildLineSegments(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SyncedReveal(
                progress: _revealedHeight,
                contentKey: _contentKey,
                scaleIn: true,
                child: const _Dot(),
              ),
              const SizedBox(height: 40),
              _SectionRow(
                left: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(-0.08, 0),
                  child: const _TextBlock(
                    title: "What's Going Wrong",
                    body:
                        "Managing cash flow shouldn't feel like trying to predict "
                        "the future. But with scattered financial data, delayed "
                        "payments, and changing expenses, businesses often "
                        "struggle to see where their cash stands, and what "
                        "they'll need next.",
                  ),
                ),
                right: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(0.08, 0),
                  child: const _ImageBlock(asset: 'assets/images/pro1.jpg'),
                ),
              ),
              const SizedBox(height: 40),
              SyncedReveal(
                progress: _revealedHeight,
                contentKey: _contentKey,
                scaleIn: true,
                child: const _Dot(),
              ),
              const SizedBox(height: 40),
              _SectionRow(
                left: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(-0.08, 0),
                  child: const _ImageBlock(asset: 'assets/images/pro2.jpg'),
                ),
                right: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(0.08, 0),
                  child: const _TextBlock(
                    title: 'How It Happens',
                    body:
                        'A delayed invoice, an unexpected expense, or changing '
                        'payment patterns can quickly create a cash gap. '
                        'Without intelligent analysis, these warning signs can '
                        'go unnoticed until they start affecting important '
                        'business decisions.',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SyncedReveal(
                progress: _revealedHeight,
                contentKey: _contentKey,
                scaleIn: true,
                child: const _Dot(),
              ),
              const SizedBox(height: 40),
              _SectionRow(
                left: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(-0.08, 0),
                  child: const _TextBlock(
                    title: 'Meet Cash OverFlow',
                    body:
                        'Powered by AI, Cash OverFlow analyzes your financial '
                        'data, identifies patterns, forecasts future cash '
                        'positions, and detects potential gaps before they '
                        'become problems. Turn complex numbers into clear, '
                        'actionable insights and make smarter decisions with '
                        'confidence.',
                    boldWord: 'Cash OverFlow',
                  ),
                ),
                right: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(0.08, 0),
                  child: const _ImageBlock(asset: 'assets/images/pro3.jpg'),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                key: _captionKey,
                child: SyncedReveal(
                  progress: _revealedHeight,
                  contentKey: _contentKey,
                  offset: const Offset(0, 0.08),
                  child: const Text(
                    'See Ahead. Act Smarter.',
                    style: TextStyle(
                      color: Color(0xFFFCFCFC),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SyncedReveal(
                progress: _revealedHeight,
                contentKey: _contentKey,
                scaleIn: true,
                child: const _Dot(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SyncedReveal extends StatefulWidget {
  const SyncedReveal({
    super.key,
    required this.child,
    required this.progress,
    required this.contentKey,
    this.offset = const Offset(0, 0.08),
    this.scaleIn = false,
    this.duration = const Duration(milliseconds: 500),
    this.leadDistance = 40,
  });

  final Widget child;
  final double progress;
  final GlobalKey contentKey;
  final Offset offset;
  final bool scaleIn;
  final Duration duration;
  final double leadDistance;

  @override
  State<SyncedReveal> createState() => _SyncedRevealState();
}

class _SyncedRevealState extends State<SyncedReveal> {
  final GlobalKey _key = GlobalKey();
  double? _anchorY;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant SyncedReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_anchorY == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    final itemBox = _key.currentContext?.findRenderObject() as RenderBox?;
    final contentBox =
        widget.contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (itemBox == null ||
        contentBox == null ||
        !itemBox.attached ||
        !contentBox.attached) {
      return;
    }
    final pos = itemBox.localToGlobal(Offset.zero, ancestor: contentBox);
    if (mounted) setState(() => _anchorY = pos.dy);
  }

  @override
  Widget build(BuildContext context) {
    final visible =
        _anchorY != null && widget.progress >= _anchorY! - widget.leadDistance;
    final opacityChild = AnimatedOpacity(
      key: _key,
      opacity: visible ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: widget.child,
    );
    if (widget.scaleIn) {
      return AnimatedScale(
        scale: visible ? 1 : 0.3,
        duration: widget.duration,
        curve: Curves.easeOutBack,
        child: opacityChild,
      );
    }
    return AnimatedSlide(
      offset: visible ? Offset.zero : widget.offset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: opacityChild,
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 40), child: left)),
          const SizedBox(width: 40),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 40), child: right)),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.title, required this.body, this.boldWord});
  final String title;
  final String body;
  final String? boldWord;

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [TextSpan(text: body)];
    if (boldWord != null && body.contains(boldWord!)) {
      final parts = body.split(boldWord!);
      spans = [
        TextSpan(text: parts[0]),
        TextSpan(
            text: boldWord,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(text: parts.length > 1 ? parts[1] : ''),
      ];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFCFCFC),
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w400),
            children: spans,
          ),
        ),
      ],
    );
  }
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF111827),
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined,
                color: Colors.white38, size: 32),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.white38, blurRadius: 10, spreadRadius: 1),
        ],
      ),
    );
  }
}
