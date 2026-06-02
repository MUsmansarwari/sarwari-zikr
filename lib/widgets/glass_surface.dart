import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.blur = 15,
    this.backgroundOpacity = 0.08,
    this.borderColor,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double blur;
  final double backgroundOpacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final innerRadius = BorderRadius.circular((borderRadius - 1.2).clamp(1.0, borderRadius));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: radius,
            ),
            padding: const EdgeInsets.all(1.2),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: backgroundOpacity),
                borderRadius: innerRadius,
                border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.18), width: 1),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
