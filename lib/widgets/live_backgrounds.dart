import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/preferences_provider.dart';
import 'liquid_background_layer.dart';

Widget buildThemeBackground(AppBackgroundTheme theme) {
  switch (theme.kind) {
    case ThemeKind.liveAurora:
      return const AuroraBackground();
    case ThemeKind.liveFireflies:
      return const FirefliesBackground();
    case ThemeKind.liveFluid:
      return const FluidWavesBackground();
    case ThemeKind.liveNightSky:
      return const NightSkyBackground();
    case ThemeKind.liveCalmRain:
      return const CalmRainBackground();
    case ThemeKind.static:
      return LiquidBackgroundLayer(theme: theme);
  }
}

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _frames = <_AuroraFrame>[
    _AuroraFrame(
      begin: Alignment(-1.0, -0.8),
      end: Alignment(0.9, 0.8),
      colors: [Color(0xFF2B1A4F), Color(0xFF632951), Color(0xFFB83F33), Color(0xFF9C4F1D)],
    ),
    _AuroraFrame(
      begin: Alignment(-0.8, 0.9),
      end: Alignment(0.6, -0.7),
      colors: [Color(0xFF1A0E36), Color(0xFF3D1E61), Color(0xFF7A2F6E), Color(0xFFE66F3C)],
    ),
    _AuroraFrame(
      begin: Alignment(0.7, -0.9),
      end: Alignment(-0.6, 0.9),
      colors: [Color(0xFF1A0C26), Color(0xFF522063), Color(0xFFD34F5C), Color(0xFFF28B50)],
    ),
    _AuroraFrame(
      begin: Alignment(-0.9, 0.2),
      end: Alignment(0.9, -0.4),
      colors: [Color(0xFF2A0E26), Color(0xFF5C1F52), Color(0xFF8B336A), Color(0xFFEB6A3D)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scaled = _controller.value * _frames.length;
        final index = scaled.floor() % _frames.length;
        final nextIndex = (index + 1) % _frames.length;
        final t = scaled - index;

        final current = _frames[index];
        final next = _frames[nextIndex];

        final begin = Alignment.lerp(current.begin, next.begin, t)!;
        final end = Alignment.lerp(current.end, next.end, t)!;
        final colors = List<Color>.generate(current.colors.length, (i) {
          final currentColor = current.colors[i % current.colors.length];
          final nextColor = next.colors[i % next.colors.length];
          return Color.lerp(currentColor, nextColor, t)!;
        });

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
            ),
          ),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}

class _AuroraFrame {
  const _AuroraFrame({required this.begin, required this.end, required this.colors});

  final Alignment begin;
  final Alignment end;
  final List<Color> colors;
}

class FirefliesBackground extends StatefulWidget {
  const FirefliesBackground({super.key});

  @override
  State<FirefliesBackground> createState() => _FirefliesBackgroundState();
}

class _FirefliesBackgroundState extends State<FirefliesBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Firefly> _fireflies;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    final rng = Random(7);
    _fireflies = List.generate(26, (index) {
      final anchor = Offset(rng.nextDouble(), rng.nextDouble());
      final radius = lerpDouble(1.8, 3.6, rng.nextDouble())!;
      final drift = lerpDouble(10, 26, rng.nextDouble())!;
      final phase = rng.nextDouble() * pi * 2;
      final sway = lerpDouble(6, 18, rng.nextDouble())!;
      final cycles = 1 + rng.nextInt(3);
      final color = rng.nextBool() ? const Color(0xFFFFF2C2) : const Color(0xFFFFD27D);
      return _Firefly(
        anchor: anchor,
        radius: radius,
        drift: drift,
        phase: phase,
        sway: sway,
        cycles: cycles,
        color: color,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FirefliesPainter(
        progress: _controller,
        fireflies: _fireflies,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _FirefliesPainter extends CustomPainter {
  _FirefliesPainter({required this.progress, required this.fireflies}) : super(repaint: progress);

  final Animation<double> progress;
  final List<_Firefly> fireflies;

  static const _backgroundColor = Color(0xFF060912);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _backgroundColor);

    final value = progress.value;
    const twoPi = pi * 2;
    final basePhase = value * twoPi;
    final glowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (final firefly in fireflies) {
      final base = Offset(size.width * firefly.anchor.dx, size.height * firefly.anchor.dy);
      final phase = basePhase * firefly.cycles + firefly.phase;
      final offset = Offset(
        sin(phase) * firefly.drift + cos(phase * 0.8) * firefly.sway,
        cos(phase * 0.9) * firefly.drift * 0.6 + sin(phase * 0.6) * firefly.sway * 0.4,
      );
      final position = base + offset;
      final flicker = 0.25 + 0.65 * (0.5 + 0.5 * sin(phase * 1.4));
      final radius = firefly.radius * (0.9 + 0.2 * sin(phase * 0.7));

      final yNorm = (position.dy / size.height).clamp(0.0, 1.0);
      double edgeFade;
      if (yNorm < 0.15) {
        edgeFade = yNorm / 0.15;
      } else if (yNorm > 0.85) {
        edgeFade = (1 - yNorm) / 0.15;
      } else {
        edgeFade = 1.0;
      }

      final alpha = (flicker * edgeFade).clamp(0.05, 0.9);
      final color = firefly.color.withValues(alpha: alpha);

      glowPaint.color = color;
      canvas.drawCircle(position, radius * 2.4, glowPaint);
      canvas.drawCircle(position, radius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _FirefliesPainter oldDelegate) => false;
}

class _Firefly {
  const _Firefly({
    required this.anchor,
    required this.radius,
    required this.drift,
    required this.phase,
    required this.sway,
    required this.cycles,
    required this.color,
  });

  final Offset anchor;
  final double radius;
  final double drift;
  final double phase;
  final double sway;
  final int cycles;
  final Color color;
}

class FluidWavesBackground extends StatefulWidget {
  const FluidWavesBackground({super.key});

  @override
  State<FluidWavesBackground> createState() => _FluidWavesBackgroundState();
}

class _FluidWavesBackgroundState extends State<FluidWavesBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FluidWavesPainter(progress: _controller),
      child: const SizedBox.expand(),
    );
  }
}

class _FluidWavesPainter extends CustomPainter {
  _FluidWavesPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  static const _bgColor = Color(0xFF041019);
  static const _twoPi = pi * 2;

  final List<_WaveConfig> _waves = const [
    _WaveConfig(amplitude: 12, wavelength: 260, cycles: 1, height: 110, color: Color(0xFF0EA5E9), opacity: 0.30),
    _WaveConfig(amplitude: 16, wavelength: 320, cycles: 1, height: 90, color: Color(0xFF14B8A6), opacity: 0.32, phaseOffset: 0.4),
    _WaveConfig(amplitude: 10, wavelength: 420, cycles: 1, height: 70, color: Color(0xFF3B82F6), opacity: 0.22, phaseOffset: 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawRect(Offset.zero & size, paint..color = _bgColor);

    final basePhase = _twoPi * progress.value;
    for (final wave in _waves) {
      paint.color = wave.color.withValues(alpha: wave.opacity);
      final path = Path()..moveTo(0, size.height);
      final phase = basePhase * wave.cycles + wave.phaseOffset;

      for (double x = 0; x <= size.width + 8; x += 8) {
        final y = size.height - wave.height - sin((x / wave.wavelength) * _twoPi + phase) * wave.amplitude;
        path.lineTo(x, y);
      }

      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FluidWavesPainter oldDelegate) => false;
}

class _WaveConfig {
  const _WaveConfig({
    required this.amplitude,
    required this.wavelength,
    required this.cycles,
    required this.height,
    required this.color,
    required this.opacity,
    this.phaseOffset = 0,
  });

  final double amplitude;
  final double wavelength;
  final int cycles;
  final double height;
  final Color color;
  final double opacity;
  final double phaseOffset;
}

class NightSkyBackground extends StatefulWidget {
  const NightSkyBackground({super.key});

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground> with TickerProviderStateMixin {
  late final AnimationController _twinkleController;
  late final AnimationController _moonController;
  late final List<_Star> _stars;
  late List<int> _twinklingStars;
  late final Random _rng;

  @override
  void initState() {
    super.initState();
    _rng = Random(21);
    _stars = _generateStars();
    _twinklingStars = _pickTwinklingStars();

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          setState(() => _twinklingStars = _pickTwinklingStars());
        }
      })
      ..repeat(reverse: true);

    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  List<_Star> _generateStars() {
    const starCount = 70;
    return List.generate(starCount, (index) {
      final position = Offset(_rng.nextDouble(), _rng.nextDouble() * 0.9);
      final radius = lerpDouble(0.45, 1.3, _rng.nextDouble())!;
      final opacity = lerpDouble(0.25, 0.9, _rng.nextDouble())!;
      final shimmerPhase = _rng.nextDouble() * pi * 2;
      return _Star(position: position, radius: radius, opacity: opacity, shimmerPhase: shimmerPhase);
    });
  }

  List<int> _pickTwinklingStars() {
    final count = 2 + _rng.nextInt(2); // 2 or 3 stars
    final indices = <int>{};
    while (indices.length < count) {
      indices.add(_rng.nextInt(_stars.length));
    }
    return indices.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NightSkyPainter(
        stars: _stars,
        twinkleProgress: _twinkleController,
        moonProgress: _moonController,
        twinklingStars: _twinklingStars,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  _NightSkyPainter({
    required this.stars,
    required this.twinkleProgress,
    required this.moonProgress,
    required this.twinklingStars,
  }) : super(repaint: Listenable.merge([twinkleProgress, moonProgress]));

  final List<_Star> stars;
  final Animation<double> twinkleProgress;
  final Animation<double> moonProgress;
  final List<int> twinklingStars;

  static const _spaceTop = Color(0xFF030A1A);
  static const _spaceBottom = Color(0xFF01030A);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_spaceTop, _spaceBottom],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    _paintStars(canvas, size);
    _paintMoon(canvas, size);
  }

  void _paintStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final pulse = 0.55 + 0.45 * sin(twinkleProgress.value * pi * 2);
    for (var i = 0; i < stars.length; i++) {
      final star = stars[i];
      final baseAlpha = star.opacity * (0.9 + 0.1 * sin(twinkleProgress.value * pi * 2 + star.shimmerPhase));
      final isTwinkling = twinklingStars.contains(i);
      final twinkleAlpha = isTwinkling ? pulse : 1.0;
      final alpha = (baseAlpha * twinkleAlpha).clamp(0.0, 1.0);

      final position = Offset(star.position.dx * size.width, star.position.dy * size.height);
      starPaint.color = Colors.white.withValues(alpha: alpha);
      glowPaint.color = Colors.white.withValues(alpha: alpha * 0.6);

      canvas.drawCircle(position, star.radius * 2.5, glowPaint);
      canvas.drawCircle(position, star.radius, starPaint);
    }
  }

  void _paintMoon(Canvas canvas, Size size) {
    final moonRadius = 22.0;
    final x = lerpDouble(-moonRadius * 1.2, size.width + moonRadius * 1.2, moonProgress.value)!;
    final y = size.height * 0.22;
    final center = Offset(x, y);

    final glowPaint = Paint()
      ..color = const Color(0xFFE6E2D9).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    final moonPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF4F1E8), Color(0xFFE7E2D6), Color(0xFFBEB9AC)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: moonRadius));

    canvas.drawCircle(center, moonRadius * 1.9, glowPaint);
    final rect = Rect.fromCircle(center: center, radius: moonRadius);
    final path1 = Path()..addOval(rect);
    final path2 = Path()..addOval(rect.shift(const Offset(8, -6)));
    final crescent = Path.combine(PathOperation.difference, path1, path2);

    canvas.drawPath(crescent, glowPaint);
    canvas.drawPath(crescent, moonPaint);
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) =>
      !listEquals(oldDelegate.twinklingStars, twinklingStars) || oldDelegate.stars != stars;
}

class _Star {
  const _Star({
    required this.position,
    required this.radius,
    required this.opacity,
    required this.shimmerPhase,
  });

  final Offset position;
  final double radius;
  final double opacity;
  final double shimmerPhase;
}

class CalmRainBackground extends StatefulWidget {
  const CalmRainBackground({super.key});

  @override
  State<CalmRainBackground> createState() => _CalmRainBackgroundState();
}

class _CalmRainBackgroundState extends State<CalmRainBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_RainDrop> _drops = [];
  final Random _rng = Random(41);
  Size? _lastSize;
  DateTime _lastTick = DateTime.now();

  static const _backgroundLayer = _RainLayerConfig(
    count: 80,
    speedMin: 2.0,
    speedMax: 4.0,
    lengthMin: 10.0,
    lengthMax: 15.0,
    alpha: 0.05,
    strokeMin: 1.0,
    strokeMax: 1.1,
  );

  static const _midgroundLayer = _RainLayerConfig(
    count: 40,
    speedMin: 8.0,
    speedMax: 12.0,
    lengthMin: 20.0,
    lengthMax: 30.0,
    alpha: 0.15,
    strokeMin: 1.05,
    strokeMax: 1.2,
  );

  static const _foregroundLayer = _RainLayerConfig(
    count: 15,
    speedMin: 18.0,
    speedMax: 25.0,
    lengthMin: 40.0,
    lengthMax: 60.0,
    alpha: 0.3,
    strokeMin: 1.1,
    strokeMax: 1.4,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CalmRainPainter(
        controller: _controller,
        drops: _drops,
        ensureDrops: _ensureDrops,
        advanceDrops: _advanceDrops,
      ),
      child: const SizedBox.expand(),
    );
  }

  void _ensureDrops(Size size) {
    if (_lastSize == size && _drops.isNotEmpty) return;
    _drops
      ..clear()
      ..addAll(_generateLayer(size, _backgroundLayer))
      ..addAll(_generateLayer(size, _midgroundLayer))
      ..addAll(_generateLayer(size, _foregroundLayer));
    _lastSize = size;
  }

  List<_RainDrop> _generateLayer(Size size, _RainLayerConfig cfg) {
    return List.generate(cfg.count, (_) {
      final length = lerpDouble(cfg.lengthMin, cfg.lengthMax, _rng.nextDouble())!;
      final speed = lerpDouble(cfg.speedMin, cfg.speedMax, _rng.nextDouble())!;
      final strokeWidth = lerpDouble(cfg.strokeMin, cfg.strokeMax, _rng.nextDouble())!;
      final alpha = (cfg.alpha * lerpDouble(0.7, 1.0, _rng.nextDouble())!).clamp(0.0, cfg.alpha);
      return _RainDrop(
        x: _rng.nextDouble() * size.width,
        y: _rng.nextDouble() * size.height,
        length: length,
        speed: speed,
        alpha: alpha,
        strokeWidth: strokeWidth,
      );
    });
  }

  void _advanceDrops(Size size) {
    final now = DateTime.now();
    final frameFactor = (now.difference(_lastTick).inMicroseconds / (Duration.microsecondsPerSecond / 60))
        .clamp(0.4, 3.0);
    _lastTick = now;

    for (final drop in _drops) {
      drop.y += drop.speed * frameFactor;
      if (drop.y > size.height) {
        drop.y = -drop.length - _rng.nextDouble() * 40;
        drop.x = _rng.nextDouble() * size.width;
      }
    }
  }
}

class _CalmRainPainter extends CustomPainter {
  _CalmRainPainter({
    required this.controller,
    required this.drops,
    required this.ensureDrops,
    required this.advanceDrops,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final List<_RainDrop> drops;
  final void Function(Size size) ensureDrops;
  final void Function(Size size) advanceDrops;

  @override
  void paint(Canvas canvas, Size size) {
    ensureDrops(size);
    advanceDrops(size);

    final rect = Offset.zero & size;
    final mistBase = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A202C),
          Color(0xFF1D2835),
          Color(0xFF2E3C48),
          Color(0xFF6BA0A3),
        ],
        stops: [0.0, 0.42, 0.74, 1.0],
      ).createShader(rect);

    final fogGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.65),
        radius: 1.05,
        colors: [
          const Color(0xFF9BBEC0).withValues(alpha: 0.28),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, mistBase);
    canvas.drawRect(rect, fogGlow);

    final paint = Paint()..strokeCap = StrokeCap.round;
    for (final drop in drops) {
      final start = Offset(drop.x, drop.y);
      final end = Offset(drop.x, drop.y + drop.length);
      paint
        ..strokeWidth = drop.strokeWidth
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: drop.alpha),
          ],
        ).createShader(Rect.fromPoints(start, end));

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CalmRainPainter oldDelegate) => false;
}

class _RainDrop {
  _RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.alpha,
    required this.strokeWidth,
  });

  double x;
  double y;
  double length;
  double speed;
  double alpha;
  double strokeWidth;
}

class _RainLayerConfig {
  const _RainLayerConfig({
    required this.count,
    required this.speedMin,
    required this.speedMax,
    required this.lengthMin,
    required this.lengthMax,
    required this.alpha,
    required this.strokeMin,
    required this.strokeMax,
  });

  final int count;
  final double speedMin;
  final double speedMax;
  final double lengthMin;
  final double lengthMax;
  final double alpha;
  final double strokeMin;
  final double strokeMax;
}

