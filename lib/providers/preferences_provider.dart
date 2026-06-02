import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, urdu }

enum ThemeKind { static, liveAurora, liveFireflies, liveFluid, liveNightSky, liveCalmRain }

class AppBackgroundTheme {
  const AppBackgroundTheme({
    required this.id,
    required this.name,
    required this.baseColor,
    required this.blobColors,
    this.kind = ThemeKind.static,
  });

  final String id;
  final String name;
  final Color baseColor;
  final List<Color> blobColors;
  final ThemeKind kind;

  bool get isLive => kind != ThemeKind.static;
}

class PreferencesProvider extends ChangeNotifier {
  static const _soundKey = 'pref_sound';
  static const _vibrationKey = 'pref_vibration';
  static const _languageKey = 'pref_language';
  static const _themeKey = 'pref_theme_gradient';
  static const _soundFileKey = 'pref_selected_sound';

  bool _soundOn = true;
  bool _vibrationOn = true;
  AppLanguage _language = AppLanguage.english;
  int _themeIndex = 0;
  String _selectedSound = 'Click.mp3';
  bool _isInitialized = false;

  bool get soundOn => _soundOn;
  bool get vibrationOn => _vibrationOn;
  AppLanguage get language => _language;
  int get themeIndex => _themeIndex;
  String get selectedSound => _selectedSound;
  bool get isInitialized => _isInitialized;
  TextDirection get textDirection => _language == AppLanguage.urdu ? TextDirection.rtl : TextDirection.ltr;
  AppBackgroundTheme get currentTheme => themes[_themeIndex % themes.length];

  static const themes = <AppBackgroundTheme>[
    AppBackgroundTheme(
      id: 'ocean_depth',
      name: 'Ocean Depth',
      baseColor: Color(0xFF060F24),
      blobColors: [
        Color(0xFF0EA5E9),
        Color(0xFF22D3EE),
        Color(0xFF1E3A8A),
      ],
    ),
    AppBackgroundTheme(
      id: 'sunset_glow',
      name: 'Sunset Glow',
      baseColor: Color(0xFF1A0A0F),
      blobColors: [
        Color(0xFFFF7E5F),
        Color(0xFFFF3D7F),
        Color(0xFFFFB84C),
      ],
    ),
    AppBackgroundTheme(
      id: 'aurora_neon',
      name: 'Aurora Neon',
      baseColor: Color(0xFF120624),
      blobColors: [
        Color(0xFF10B981),
        Color(0xFF22D3EE),
        Color(0xFFEC4899),
      ],
    ),
    AppBackgroundTheme(
      id: 'dynamic_mac_aura',
      name: 'Dynamic Mac Aura',
      baseColor: Color(0xFF0B1021),
      blobColors: [
        Color(0xFF8EC5FC),
        Color(0xFFE0C3FC),
        Color(0xFF9FACE6),
        Color(0xFF74EBD5),
      ],
    ),
    AppBackgroundTheme(
      id: 'live_aurora',
      name: 'Aurora Glow (Live)',
      baseColor: Color(0xFF170D26),
      blobColors: [
        Color(0xFF2B1A4F),
        Color(0xFF8C3B5E),
        Color(0xFFE66F3C),
      ],
      kind: ThemeKind.liveAurora,
    ),
    AppBackgroundTheme(
      id: 'live_fireflies',
      name: 'Noor Fireflies (Live)',
      baseColor: Color(0xFF05070F),
      blobColors: [
        Color(0xFFFFF2C2),
        Color(0xFFFFD27D),
        Color(0xFF0C1222),
      ],
      kind: ThemeKind.liveFireflies,
    ),
    AppBackgroundTheme(
      id: 'live_fluid',
      name: 'Calm Waves (Live)',
      baseColor: Color(0xFF041019),
      blobColors: [
        Color(0xFF0EA5E9),
        Color(0xFF14B8A6),
        Color(0xFF3B82F6),
      ],
      kind: ThemeKind.liveFluid,
    ),
    AppBackgroundTheme(
      id: 'live_night_sky',
      name: 'Night Sky (Live)',
      baseColor: Color(0xFF050910),
      blobColors: [
        Color(0xFF0B1C33),
        Color(0xFF0F2745),
        Color(0xFF0A1224),
      ],
      kind: ThemeKind.liveNightSky,
    ),
    AppBackgroundTheme(
      id: 'live_calm_rain',
      name: 'Calm Rain (Live)',
      baseColor: Color(0xFF1A202C),
      blobColors: [
        Color(0xFF1A202C),
        Color(0xFF2B3544),
        Color(0xFF6BA0A3),
      ],
      kind: ThemeKind.liveCalmRain,
    ),
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _load();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    _soundOn = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setVibration(bool value) async {
    _vibrationOn = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await _persist();
    notifyListeners();
  }

  Future<void> setThemeIndex(int index) async {
    _themeIndex = index % themes.length;
    await _persist();
    notifyListeners();
  }

  Future<void> setSelectedSound(String fileName) async {
    _selectedSound = fileName;
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _soundOn = prefs.getBool(_soundKey) ?? true;
    _vibrationOn = prefs.getBool(_vibrationKey) ?? true;
    final lang = prefs.getString(_languageKey);
    _language = lang == 'ur' ? AppLanguage.urdu : AppLanguage.english;
    _themeIndex = prefs.getInt(_themeKey) ?? 0;
    if (_themeIndex < 0 || _themeIndex >= themes.length) {
      _themeIndex = 0; // fallback to default static when legacy Rain index is found
    }
    _selectedSound = prefs.getString(_soundFileKey) ?? 'Click.mp3';
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, _soundOn);
    await prefs.setBool(_vibrationKey, _vibrationOn);
    await prefs.setString(_languageKey, _language == AppLanguage.urdu ? 'ur' : 'en');
    await prefs.setInt(_themeKey, _themeIndex);
    await prefs.setString(_soundFileKey, _selectedSound);
  }
}
