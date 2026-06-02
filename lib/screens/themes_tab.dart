import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/preferences_provider.dart';
import '../widgets/glass_surface.dart';
import '../l10n/strings.dart';

class ThemesTab extends StatelessWidget {
  const ThemesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefs, _) {
        final themes = PreferencesProvider.themes.asMap().entries.toList();
        final staticThemes = themes.where((entry) => !entry.value.isLive).toList();
        final liveThemes = themes.where((entry) => entry.value.isLive).toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: ListView(
              children: [
                Text(
                  Strings.themesTitle(prefs.language),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Text(
                  Strings.staticThemes(prefs.language),
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: staticThemes.length,
                  itemBuilder: (context, index) {
                    final entry = staticThemes[index];
                    final themeIndex = entry.key;
                    final theme = entry.value;
                    final isActive = prefs.themeIndex == themeIndex;
                    return GestureDetector(
                      onTap: () => prefs.setThemeIndex(themeIndex),
                      child: _GlassCard(
                        borderColor: isActive ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2),
                        child: Stack(
                          children: [
                            _ThemePreview(theme: theme, isLive: theme.isLive),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      theme.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                                        ),
                                        child: Text(
                                          Strings.active(prefs.language),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Text(
                  Strings.livePremiumThemes(prefs.language),
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: liveThemes.length,
                  itemBuilder: (context, index) {
                    final entry = liveThemes[index];
                    final themeIndex = entry.key;
                    final theme = entry.value;
                    final isActive = prefs.themeIndex == themeIndex;
                    return GestureDetector(
                      onTap: () => prefs.setThemeIndex(themeIndex),
                      child: _GlassCard(
                        borderColor: isActive ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.25),
                        child: Stack(
                          children: [
                            _ThemePreview(theme: theme, isLive: true),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.auto_awesome, size: 16, color: Colors.white70),
                                    SizedBox(width: 6),
                                    Text('Live', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      theme.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                                        ),
                                        child: Text(
                                          Strings.active(prefs.language),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.theme, this.isLive = false});

  final AppBackgroundTheme theme;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: theme.baseColor,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: theme.baseColor)),
            ..._buildBlobs(),
            if (isLive)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.02),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBlobs() {
    const configs = [
      _PreviewBlob(alignment: Alignment(-1.0, -1.0), size: 200),
      _PreviewBlob(alignment: Alignment(1.0, -0.2), size: 160),
      _PreviewBlob(alignment: Alignment(-0.9, 1.0), size: 220),
    ];

    return List.generate(configs.length, (index) {
      final cfg = configs[index];
      final primary = theme.blobColors[index % theme.blobColors.length];
      final accent = theme.blobColors[(index + 1) % theme.blobColors.length];
      return Positioned.fill(
        child: Align(
          alignment: cfg.alignment,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: cfg.size,
              height: cfg.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.9),
                    accent.withValues(alpha: 0.45),
                    primary.withValues(alpha: 0.04),
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

class _PreviewBlob {
  const _PreviewBlob({required this.alignment, required this.size});

  final Alignment alignment;
  final double size;
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: GlassSurface(
        borderRadius: 18,
        backgroundOpacity: 0.06,
        borderColor: borderColor,
        child: child,
      ),
    );
  }
}
