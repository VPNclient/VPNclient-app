import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Figma "Loading" component (/Main/Lost-Internet-Start..5, Main-On2): 4 static
/// 20px dots spaced 14px apart (rgb(48,63,73) = AppColors.fg1), revealed by a
/// clip window whose left/width were captured across the six Figma frames
/// (Start,1,2,3,4,5) — a left-to-right reveal that collapses to the last dot
/// before looping. Values are the exact Figma pixel keyframes, not approximated.
class LoadingDots extends StatefulWidget {
  final Color color;
  const LoadingDots({super.key, this.color = AppColors.fg1});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  static const double _dot = 20;
  static const double _gap = 14;
  static const double _step = _dot + _gap; // 34
  static const double _total = _dot * 4 + _gap * 3; // 122

  // (left, width) window keyframes, straight from Lost-Internet-Start/1/2/3/4/5.
  static const List<Offset> _frames = [
    Offset(0, _total), // Start — all 4 dots
    Offset(0, _dot), // 1 — dot 0 only
    Offset(0, _dot + _step), // 2 — dots 0-1 (54)
    Offset(0, _dot + _step * 2), // 3 — dots 0-2 (88)
    Offset(0, _total), // 4 — all 4 again
    Offset(_step * 3, _dot), // 5 — dot 3 only
  ];

  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(right: i == 3 ? 0 : _gap),
          child: Container(
            width: _dot,
            height: _dot,
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        ),
      ),
    );

    return SizedBox(
      width: _total,
      height: _dot,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final segCount = _frames.length;
          final t = _c.value * segCount;
          final idx = t.floor().clamp(0, segCount - 1);
          final frac = (t - idx).clamp(0.0, 1.0).toDouble();
          final from = _frames[idx];
          final to = _frames[(idx + 1) % segCount];
          final left = from.dx + (to.dx - from.dx) * frac;
          final width = from.dy + (to.dy - from.dy) * frac;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: left,
                width: width,
                height: _dot,
                child: ClipRect(
                  child: OverflowBox(
                    minWidth: 0,
                    maxWidth: _total,
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(-left, 0),
                      child: dots,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
