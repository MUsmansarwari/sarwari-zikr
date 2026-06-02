import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:audioplayers/audioplayers.dart';

import '../providers/preferences_provider.dart';
import '../providers/zikr_provider.dart';
import '../l10n/strings.dart';
import '../widgets/live_backgrounds.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _autoOn = false;
  Timer? _autoTimer;
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;
  late final AudioPlayer _audioPlayer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    _pressController.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer(playerId: 'count_sound');
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 340),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_autoOn) {
        _autoTimer?.cancel();
        setState(() => _autoOn = false);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ZikrProvider, PreferencesProvider>(
      builder: (context, zikrProvider, prefs, _) {
        if (!zikrProvider.isInitialized || zikrProvider.zikrs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final zikrs = zikrProvider.zikrs;
        final currentZikr = zikrProvider.activeZikr;
        final progress = currentZikr.targetCount == 0
            ? 0.0
            : (currentZikr.currentCount / currentZikr.targetCount).clamp(0.0, 1.0);

        return GlassPage(
          background: buildThemeBackground(prefs.currentTheme),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Strings.glassZikrTitle(prefs.language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassCard(
                      quality: GlassQuality.standard,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    currentZikr.nameEn,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      currentZikr.nameUr,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${Strings.countLabel(prefs.language)}: ',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  '${currentZikr.currentCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Text(
                                  '${Strings.targetLabel(prefs.language)}: ${currentZikr.targetCount}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withValues(alpha: 0.95),
                                                Colors.cyanAccent.withValues(alpha: 0.75),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withValues(alpha: 0.35),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _GlassActionButton(
                                icon: Icons.remove,
                                label: Strings.minus(prefs.language),
                                active: false,
                                onTap: () => _decrement(zikrProvider, prefs, currentZikr.id),
                                hapticsEnabled: prefs.vibrationOn,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _GlassActionButton(
                                icon: Icons.refresh,
                                label: Strings.reset(prefs.language),
                                active: false,
                                onTap: () => _resetWithConfirm(zikrProvider, prefs, currentZikr.id),
                                hapticsEnabled: prefs.vibrationOn,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _GlassActionButton(
                                icon: _autoOn ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                label: Strings.auto(prefs.language),
                                active: _autoOn,
                                onTap: () => _toggleAuto(zikrProvider, prefs, currentZikr.id),
                                hapticsEnabled: prefs.vibrationOn,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _GlassActionButton(
                                icon: Icons.swap_horiz,
                                label: Strings.switchZikr(prefs.language),
                                active: false,
                                onTap: () => _switchZikr(zikrs.length, prefs, zikrProvider),
                                hapticsEnabled: prefs.vibrationOn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _handleCountTap(zikrProvider, prefs, currentZikr.id),
                        onTapDown: (_) {
                          _pressController.forward();
                          _maybeLightImpact(prefs);
                        },
                        onTapUp: (_) => _releasePress(),
                        onTapCancel: _releasePress,
                        child: GlassCard(
                          quality: GlassQuality.standard,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                            child: ScaleTransition(
                              scale: _pressScale,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                                      child: Container(
                                        width: 260,
                                        height: 260,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.26),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                            stops: const [0.0, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${currentZikr.currentCount}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 70,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        '${Strings.targetLabel(prefs.language)}: ${currentZikr.targetCount}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCountTap(ZikrProvider provider, PreferencesProvider prefs, String id) {
    _playCountSound(prefs);
    _increment(provider, prefs, id, playSound: false);
  }

  Future<void> _increment(ZikrProvider provider, PreferencesProvider prefs, String id, {bool playSound = true}) async {
    await provider.increment(id);
    final updated = provider.zikrs.firstWhere((z) => z.id == id);
    final reachedTarget = updated.targetCount > 0 && updated.currentCount == updated.targetCount;
    await _playFeedback(prefs, type: reachedTarget ? _FeedbackType.longTarget : _FeedbackType.tap, playSound: playSound);
  }

  Future<void> _decrement(ZikrProvider provider, PreferencesProvider prefs, String id) async {
    await provider.decrement(id);
    await _playFeedback(prefs, type: _FeedbackType.tap);
  }

  Future<void> _resetWithConfirm(ZikrProvider provider, PreferencesProvider prefs, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: GlassCard(
              quality: GlassQuality.standard,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.resetQuestion(prefs.language),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: GlassCard(
                            quality: GlassQuality.standard,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Text(
                                Strings.cancel(prefs.language),
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(true),
                          child: GlassCard(
                            quality: GlassQuality.standard,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Text(
                                Strings.ok(prefs.language),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await provider.reset(id);
      await _playFeedback(prefs, type: _FeedbackType.doublePulse);
    }
  }

  void _switchZikr(int length, PreferencesProvider prefs, ZikrProvider provider) {
    if (length == 0) return;
    final nextIndex = (provider.activeIndex + 1) % length;
    final nextId = provider.zikrs[nextIndex].id;
    provider.setActive(nextId);
    _playFeedback(prefs, type: _FeedbackType.doublePulse);
  }

  void _toggleAuto(ZikrProvider provider, PreferencesProvider prefs, String id) {
    if (_autoOn) {
      _autoTimer?.cancel();
      setState(() => _autoOn = false);
      return;
    }

    _showAutoSpeedSheet(prefs).then((duration) {
      if (!mounted || duration == null) return;
      _autoTimer?.cancel();
      _autoTimer = Timer.periodic(duration, (_) {
        if (!mounted) return;
        _increment(provider, prefs, id);
      });
      setState(() => _autoOn = true);
    });
  }

  Future<Duration?> _showAutoSpeedSheet(PreferencesProvider prefs) async {
    final taps = <DateTime>[];
    return showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              quality: GlassQuality.standard,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setSheetState) {
                    void registerTap() {
                      taps.add(DateTime.now());
                      if (taps.length > 3) taps.removeAt(0);
                      setSheetState(() {});
                      if (taps.length == 3) {
                        final first = taps[0];
                        final second = taps[1];
                        final third = taps[2];
                        final diff1 = second.difference(first).inMilliseconds;
                        final diff2 = third.difference(second).inMilliseconds;
                        final avgMs = ((diff1 + diff2) / 2).clamp(150, 2000).toInt();
                        Navigator.of(context).pop(Duration(milliseconds: avgMs));
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Strings.autoSpeedTitle(prefs.language),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          Strings.autoSpeedHint(prefs.language),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: registerTap,
                          child: GlassCard(
                            quality: GlassQuality.standard,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.touch_app_rounded, color: Colors.white),
                                    const SizedBox(height: 8),
                                    Text(
                                      Strings.autoSpeedHint(prefs.language),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      Strings.tapsProgress(prefs.language, taps.length),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: GlassCard(
                              quality: GlassQuality.standard,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Text(
                                  Strings.cancel(prefs.language),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _playFeedback(PreferencesProvider prefs, { _FeedbackType type = _FeedbackType.tap, bool playSound = true }) async {
    if (prefs.soundOn && playSound) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (!prefs.vibrationOn) return;

    switch (type) {
      case _FeedbackType.tap:
        await HapticFeedback.selectionClick();
        break;
      case _FeedbackType.doublePulse:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 55));
        await HapticFeedback.lightImpact();
        break;
      case _FeedbackType.longTarget:
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 350));
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 350));
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 250));
        await HapticFeedback.vibrate();
        break;
    }
  }

  void _releasePress() {
    if (_pressController.isAnimating && _pressController.status == AnimationStatus.forward) {
      _pressController.reverse();
    } else {
      _pressController.reverse();
    }
  }

  void _maybeLightImpact(PreferencesProvider prefs) {
    if (prefs.vibrationOn) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _playCountSound(PreferencesProvider prefs) async {
    if (!prefs.soundOn) return;
    final file = _normalizeSoundFile(prefs.selectedSound);
    final source = AssetSource('sounds/$file');
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(source, volume: 1.0);
    } catch (_) {
      // Swallow errors to avoid blocking tap feedback
    }
  }

  String _normalizeSoundFile(String file) {
    final lower = file.toLowerCase();
    if (lower == 'click.mp3') return 'Click.mp3';
    if (lower == 'pop.mp3') return 'pop.mp3';
    if (lower == 'soft.mp3') return 'soft.mp3';
    return 'Click.mp3';
  }
}

enum _FeedbackType { tap, doublePulse, longTarget }

class _GlassActionButton extends StatefulWidget {
  const _GlassActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.hapticsEnabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool hapticsEnabled;

  @override
  State<_GlassActionButton> createState() => _GlassActionButtonState();
}

class _GlassActionButtonState extends State<_GlassActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _controller.forward();
  void _handleTapUp(TapUpDetails _) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  void _maybeImpact() {
    if (widget.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? Colors.white : Colors.white70;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (details) {
        _handleTapDown(details);
        _maybeImpact();
      },
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Column(
        children: [
          ScaleTransition(
            scale: _scale,
            child: GlassCard(
              quality: GlassQuality.standard,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 68,
                  alignment: Alignment.center,
                  child: Icon(widget.icon, color: color, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
