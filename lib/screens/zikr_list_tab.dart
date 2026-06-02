import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/preferences_provider.dart';
import '../providers/zikr_provider.dart';
import '../l10n/strings.dart';
import '../widgets/live_backgrounds.dart';

class ZikrListTab extends StatefulWidget {
  const ZikrListTab({super.key, required this.onSelectZikr});

  final VoidCallback onSelectZikr;

  @override
  State<ZikrListTab> createState() => _ZikrListTabState();
}

class _ZikrListTabState extends State<ZikrListTab> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  late final AnimationController _listController;
  int _lastCount = 0;

  @override
  void dispose() {
    _listController.dispose();
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ZikrProvider, PreferencesProvider>(
      builder: (context, provider, prefs, _) {
        final zikrs = provider.zikrs;
        return GlassPage(
          background: buildThemeBackground(prefs.currentTheme),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Strings.zikrList(prefs.language),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: zikrs.length + 1,
                        separatorBuilder: (context, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index == zikrs.length) {
                            return _AddZikrButton(
                              label: Strings.addCustomZikr(prefs.language),
                              onTap: () => _showAddDialog(context, provider),
                            );
                          }
                          if (_lastCount != zikrs.length) {
                            _lastCount = zikrs.length;
                            _listController.forward(from: 0);
                          }
                          final start = (index * 0.05).clamp(0.0, 0.8);
                          final end = (start + 0.35).clamp(0.0, 1.0);
                          final animation = CurvedAnimation(
                            parent: _listController,
                            curve: Interval(start, end, curve: Curves.easeOutCubic),
                          );
                          final zikr = zikrs[index];
                          final progress = zikr.targetCount == 0
                              ? 0.0
                              : (zikr.currentCount / zikr.targetCount).clamp(0.0, 1.0);
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              final opacity = animation.value;
                              final dy = 24 * (1 - animation.value);
                              return Opacity(
                                opacity: opacity,
                                child: Transform.translate(
                                  offset: Offset(0, dy),
                                  child: child,
                                ),
                              );
                            },
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () async {
                                await provider.setActive(zikr.id);
                                widget.onSelectZikr();
                              },
                              child: GlassCard(
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
                                              zikr.nameEn,
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
                                                zikr.nameUr,
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (zikr.isCustom)
                                            IconButton(
                                              splashRadius: 20,
                                              onPressed: () => provider.removeCustom(zikr.id),
                                              icon: const Icon(Icons.delete, color: Colors.white70),
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
                                            '${zikr.currentCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          Text(
                                            '${Strings.targetLabel(prefs.language)}: ${zikr.targetCount}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context, ZikrProvider provider) async {
    _nameController.clear();
    _targetController.clear();
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        final prefs = context.read<PreferencesProvider>();
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: _GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.addCustomZikr(prefs.language),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(Strings.nameHint(prefs.language)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(Strings.targetHint(prefs.language)),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final target = int.tryParse(_targetController.text.trim());
                        if (name.isEmpty || target == null || target <= 0) {
                          return;
                        }
                        final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                        provider.upsertCustom(
                          provider
                              .zikrs.first
                              .copyWith(id: id, nameEn: name, nameUr: name, targetCount: target, currentCount: 0, isCustom: true),
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(Strings.add(prefs.language)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }
}

class _AddZikrButton extends StatelessWidget {
  const _AddZikrButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: GlassCard(
        quality: GlassQuality.standard,
        child: SizedBox(
          height: 64,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    final innerRadius = BorderRadius.circular(22);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                    color: Colors.white.withValues(alpha: 0.08),
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
                  padding: const EdgeInsets.all(18),
                  child: child,
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 8,
                  child: IgnorePointer(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.14),
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
    );
  }
}
