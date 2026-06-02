import 'dart:ui';

import 'package:flutter/material.dart';

class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = 24,
    this.blurSigma = 20,
    this.innerBackgroundOpacity = 0.08,
    this.topHighlightOpacity = 0.14,
    this.topHighlightHeight = 38,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blurSigma;
  final double innerBackgroundOpacity;
  final double topHighlightOpacity;
  final double topHighlightHeight;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final innerRadius = BorderRadius.circular((borderRadius - 2).clamp(2.0, borderRadius));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.26), width: 1.3),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(1.4),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    top: -12,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                      child: Container(
                        width: 180,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: innerRadius,
                      color: Colors.white.withValues(alpha: innerBackgroundOpacity),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    padding: padding,
                    child: child,
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 8,
                    child: IgnorePointer(
                      child: Container(
                        height: topHighlightHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius * 0.65),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: topHighlightOpacity),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
