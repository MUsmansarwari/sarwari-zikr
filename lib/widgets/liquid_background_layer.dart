import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../providers/preferences_provider.dart';

class LiquidBackgroundLayer extends StatefulWidget {
  const LiquidBackgroundLayer({
    super.key,
    required this.theme,
  });

  final AppBackgroundTheme theme;

  @override
  State<LiquidBackgroundLayer> createState() => _LiquidBackgroundLayerState();
}

class _LiquidBackgroundLayerState extends State<LiquidBackgroundLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isDynamic => widget.theme.id == 'dynamic_mac_aura';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (_isDynamic) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LiquidBackgroundLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme.name != widget.theme.name) {
      if (_isDynamic) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blobs = _buildBlobs(widget.theme.blobColors);
    final layer = Container(
      decoration: BoxDecoration(color: widget.theme.baseColor),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: widget.theme.baseColor)),
          ...blobs,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!_isDynamic) return layer;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx = lerpDouble(-0.08, 0.08, sin(pi * 2 * t) * 0.5 + 0.5)!;
        final dy = lerpDouble(-0.06, 0.06, cos(pi * 2 * t) * 0.5 + 0.5)!;
        return Transform.translate(
          offset: Offset(40 * dx, 32 * dy),
          child: child,
        );
      },
      child: layer,
    );
  }

  List<Widget> _buildBlobs(List<Color> palette) {
    const configs = [
      _BlobConfig(alignment: Alignment(-1.05, -0.9), size: 460),
      _BlobConfig(alignment: Alignment(1.05, -0.4), size: 380),
      _BlobConfig(alignment: Alignment(-0.9, 1.0), size: 520),
      _BlobConfig(alignment: Alignment(1.1, 1.0), size: 360),
    ];

    return List.generate(configs.length, (index) {
      final config = configs[index];
      final primary = palette[index % palette.length];
      final accent = palette[(index + 1) % palette.length];
      return Positioned.fill(
        child: Align(
          alignment: config.alignment,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: config.size,
              height: config.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.9),
                    accent.withValues(alpha: 0.5),
                    primary.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _BlobConfig {
  const _BlobConfig({required this.alignment, required this.size});

  final Alignment alignment;
  final double size;
}
