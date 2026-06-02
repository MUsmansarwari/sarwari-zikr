import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Premium glossy loader for the splash/loading overlay.
class PremiumLiquidLoader extends StatefulWidget {
  const PremiumLiquidLoader({super.key});

  @override
  State<PremiumLiquidLoader> createState() => _PremiumLiquidLoaderState();
}

class _PremiumLiquidLoaderState extends State<PremiumLiquidLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(180, 180),
                painter: _LiquidLoaderPainter(progress: _controller.value),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.6),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiquidLoaderPainter extends CustomPainter {
  const _LiquidLoaderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.43;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepShader = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: const [
        Color(0xFF7CF3FF),
        Color(0xFFF7C7E8),
        Color(0xFFD2C4FF),
        Color(0xFF7CF3FF),
      ],
      stops: const [0.0, 0.32, 0.66, 1.0],
      transform: GradientRotation(progress * 2 * pi),
    ).createShader(rect);

    final borderPaint = Paint()
      ..shader = sweepShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * pi, false, borderPaint);

    final sheenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
        transform: GradientRotation(-progress * 2 * pi),
      ).createShader(rect);

    canvas.drawArc(rect.deflate(10), 0, 2 * pi, false, sheenPaint);

    final subtleGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.cyanAccent.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.12),
        ],
      ).createShader(rect.inflate(2));

    canvas.drawArc(rect.inflate(2), 0, 2 * pi, false, subtleGlow);
  }

  @override
  bool shouldRepaint(covariant _LiquidLoaderPainter oldDelegate) => oldDelegate.progress != progress;
}
