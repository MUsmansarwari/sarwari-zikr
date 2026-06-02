import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/preferences_provider.dart';
import '../widgets/glass_surface.dart';
import '../widgets/live_backgrounds.dart';
import '../l10n/strings.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefs, _) {
        return GlassPage(
          background: buildThemeBackground(prefs.currentTheme),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Strings.settingsTitle(prefs.language),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _GlassGroup(
                            children: [
                              _SettingsTile(
                                icon: Icons.volume_up,
                                title: Strings.sound(prefs.language),
                                trailing: Switch(
                                  value: prefs.soundOn,
                                  onChanged: prefs.setSound,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: Colors.white.withValues(alpha: 0.45),
                                  inactiveThumbColor: Colors.white54,
                                  inactiveTrackColor: Colors.white24,
                                ),
                              ),
                              _SettingsTile(
                                icon: Icons.music_note,
                                title: Strings.selectSound(prefs.language),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _soundLabel(prefs),
                                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right, color: Colors.white54),
                                  ],
                                ),
                                onTap: () => _showSoundDialog(context, prefs),
                              ),
                              _Divider(),
                              _SettingsTile(
                                icon: Icons.vibration,
                                title: Strings.vibration(prefs.language),
                                trailing: Switch(
                                  value: prefs.vibrationOn,
                                  onChanged: prefs.setVibration,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: Colors.white.withValues(alpha: 0.45),
                                  inactiveThumbColor: Colors.white54,
                                  inactiveTrackColor: Colors.white24,
                                ),
                              ),
                              _Divider(),
                              _SettingsTile(
                                icon: Icons.language,
                                title: Strings.language(prefs.language),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _LanguageChip(
                                        label: 'EN',
                                        selected: prefs.language == AppLanguage.english,
                                        onTap: () => prefs.setLanguage(AppLanguage.english),
                                      ),
                                      const SizedBox(width: 8),
                                      _LanguageChip(
                                        label: 'UR',
                                        selected: prefs.language == AppLanguage.urdu,
                                        onTap: () => prefs.setLanguage(AppLanguage.urdu),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _GlassGroup(
                            children: [
                              _SettingsTile(
                                icon: Icons.share,
                                title: 'Share App',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                                onTap: () => Share.share(
                                  'Experience a calm, premium zikr counter with Sarwari Zikr. Download now and begin your zikr journey.',
                                  subject: 'Sarwari Zikr App',
                                ),
                              ),
                              _Divider(),
                              _SettingsTile(
                                icon: Icons.info_outline,
                                title: 'About Zikr App',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                                onTap: () => _showAboutDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: const [
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Developed by Usman Nawaz Sarwari',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
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
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: GlassCard(
              quality: GlassQuality.standard,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Zikr App',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Version: 1.0.0',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'This app is specially designed for the Sarwari Jamat with specific zikrs assigned by Hazrat Sakhi Sultan Baba Jani Sarkar Allah Waly.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Developed by: Usman Nawaz Sarwari',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: GlassCard(
                          quality: GlassQuality.standard,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
      },
    );
  }

  String _soundLabel(PreferencesProvider prefs) {
    switch (prefs.selectedSound.toLowerCase()) {
      case 'pop.mp3':
        return Strings.soundPop(prefs.language);
      case 'soft.mp3':
        return Strings.soundSoft(prefs.language);
      default:
        return Strings.soundClick(prefs.language);
    }
  }

  Future<void> _showSoundDialog(BuildContext context, PreferencesProvider prefs) async {
    final options = [
      ('Click.mp3', Strings.soundClick(prefs.language)),
      ('pop.mp3', Strings.soundPop(prefs.language)),
      ('soft.mp3', Strings.soundSoft(prefs.language)),
    ];

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: GlassCard(
              quality: GlassQuality.standard,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.selectSound(prefs.language),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    ...options.map((option) {
                      final file = option.$1;
                      final label = option.$2;
                      final selected = prefs.selectedSound.toLowerCase() == file.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            prefs.setSelectedSound(file);
                            Navigator.of(context).pop();
                          },
                          child: GlassCard(
                            quality: GlassQuality.standard,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  _GlassRadio(selected: selected),
                                  const SizedBox(width: 12),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: selected ? Colors.white : Colors.white70,
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassRadio extends StatelessWidget {
  const _GlassRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        color: Colors.white.withValues(alpha: selected ? 0.25 : 0.05),
      ),
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.cyanAccent.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassGroup extends StatelessWidget {
  const _GlassGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      quality: GlassQuality.standard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.trailing, this.onTap});

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: trailing,
      onTap: onTap,
      dense: true,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.white24,
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundOpacity: selected ? 0.16 : 0.1,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
