import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'providers/preferences_provider.dart';
import 'providers/zikr_provider.dart';
import 'screens/home_tab.dart';
import 'screens/settings_tab.dart';
import 'screens/themes_tab.dart';
import 'screens/zikr_list_tab.dart';
import 'l10n/strings.dart';
import 'widgets/live_backgrounds.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZikrProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: prefs.language == AppLanguage.urdu ? const Locale('ur') : const Locale('en'),
            builder: (context, child) => Directionality(
              textDirection: prefs.textDirection,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _taglineController;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _taglineOpacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeInOut),
    );
    _warmUp();
  }

  @override
  void dispose() {
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _warmUp() async {
    final prefs = context.read<PreferencesProvider>();
    final zikr = context.read<ZikrProvider>();

    await Future.wait([
      prefs.initialize(),
      zikr.initialize(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GlassZikrHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final theme = prefs.isInitialized ? prefs.currentTheme : PreferencesProvider.themes.first;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: buildThemeBackground(theme)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sarwari Zikr',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        offset: const Offset(0, 6),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    'Preparing your zikr space...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassZikrHome extends StatefulWidget {
  const GlassZikrHome({super.key});

  @override
  State<GlassZikrHome> createState() => _GlassZikrHomeState();
}

class _GlassZikrHomeState extends State<GlassZikrHome> {
  int _currentIndex = 0;
  DateTime? _lastBackPress;
  late final PageController _pageController;

  late final List<Widget> _pages;

  late List<_NavItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      _NavItem(labelBuilder: Strings.home, icon: Icons.home_rounded),
      _NavItem(labelBuilder: Strings.zikrList, icon: Icons.menu_book_rounded),
      _NavItem(labelBuilder: Strings.themes, icon: Icons.color_lens_rounded),
      _NavItem(labelBuilder: Strings.settings, icon: Icons.settings_rounded),
    ];
    _pageController = PageController(initialPage: _currentIndex);
    _pages = [
      const HomeTab(),
      ZikrListTab(onSelectZikr: _handleZikrSelectedFromList),
      const ThemesTab(),
      const SettingsTab(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        final prefs = context.read<PreferencesProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.pressBackToExit(prefs.language)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final currentTheme = prefs.isInitialized ? prefs.currentTheme : PreferencesProvider.themes.first;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _handleWillPop();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: buildThemeBackground(currentTheme)),
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: _pages,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: _FloatingNavBar(
                  items: _items.map((e) => e.copyWithLabel(e.labelBuilder(prefs.language))).toList(),
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleZikrSelectedFromList() {
    setState(() => _currentIndex = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            height: 65,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.08),
                      ],
                    ),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: _FloatingNavItem(
                              item: items[i],
                              isActive: currentIndex == i,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.white70;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: AnimatedScale(
            scale: isActive ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(item.icon, color: color),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.labelBuilder, required this.icon, this.label});

  final String Function(AppLanguage) labelBuilder;
  final IconData icon;
  final String? label;

  _NavItem copyWithLabel(String value) => _NavItem(labelBuilder: labelBuilder, icon: icon, label: value);
}

