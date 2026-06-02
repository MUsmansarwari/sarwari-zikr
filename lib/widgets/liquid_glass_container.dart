import 'dart:ui';

import 'package:flutter/material.dart';

class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(24),
    this.blurSigma = 18,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final double blurSigma;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 32,
            offset: const Offset(0, 20),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.12),
            blurRadius: 44,
            offset: const Offset(0, 10),
            spreadRadius: -20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _LiquidGlassPainter(borderRadius: borderRadius),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.2, -0.4),
                      radius: 1.2,
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassPainter extends CustomPainter {
  _LiquidGlassPainter({required this.borderRadius});

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.save();
    canvas.clipRRect(rrect);

    _paintIridescentSheen(canvas, rect);
    _paintSpecularHighlights(canvas, size);
    _paintEdgeHighlight(canvas, rrect, rect);

    canvas.restore();
  }

  void _paintIridescentSheen(Canvas canvas, Rect rect) {
    final sheenPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF96F7FF),
          Color(0xFFF7C7E8),
          Color(0xFFD2C4FF),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect)
      ..colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: 0.14), BlendMode.srcATop);

    canvas.drawRect(rect, sheenPaint);
  }

  void _paintSpecularHighlights(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final topHighlight = Path()
      ..moveTo(0, size.height * 0.10)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.00, size.width * 0.68, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.19, 0, size.height * 0.16)
      ..close();

    final leftHighlight = Path()
      ..moveTo(size.width * 0.04, 0)
      ..quadraticBezierTo(size.width * 0.00, size.height * 0.18, size.width * 0.10, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.16, size.height * 0.22, size.width * 0.12, 0)
      ..close();

    canvas.drawPath(topHighlight, highlightPaint);
    canvas.drawPath(leftHighlight, highlightPaint);
  }

  void _paintEdgeHighlight(Canvas canvas, RRect rrect, Rect rect) {
    final borderWidth = 2.4;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color(0x9936E0FF),
          Color(0x0036E0FF),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect.deflate(borderWidth / 2), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassPainter oldDelegate) => oldDelegate.borderRadius != borderRadius;
}
