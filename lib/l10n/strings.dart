import '../providers/preferences_provider.dart';

class Strings {
  static bool _isUrdu(AppLanguage language) => language == AppLanguage.urdu;

  static String home(AppLanguage l) => _isUrdu(l) ? 'گھر' : 'Home';
  static String zikrList(AppLanguage l) => _isUrdu(l) ? 'ذکر کی فہرست' : 'Zikr List';
  static String themes(AppLanguage l) => _isUrdu(l) ? 'تھیمز' : 'Themes';
  static String settings(AppLanguage l) => _isUrdu(l) ? 'ترتیبات' : 'Settings';

  static String glassZikrTitle(AppLanguage l) => _isUrdu(l) ? 'سروری ذکر' : 'Sarwari Zikr';
  static String themesTitle(AppLanguage l) => _isUrdu(l) ? 'تھیمز' : 'Themes';
  static String settingsTitle(AppLanguage l) => _isUrdu(l) ? 'ترتیبات' : 'Settings';
  static String staticThemes(AppLanguage l) => _isUrdu(l) ? 'جامد تھیمز' : 'Static Themes';
  static String livePremiumThemes(AppLanguage l) => _isUrdu(l) ? 'لائیو پریمیم تھیمز' : 'Live Premium Themes';

  static String minus(AppLanguage l) => _isUrdu(l) ? 'کم کریں' : 'Minus';
  static String reset(AppLanguage l) => _isUrdu(l) ? 'ری سیٹ' : 'Reset';
  static String auto(AppLanguage l) => _isUrdu(l) ? 'خودکار' : 'Auto';
  static String switchZikr(AppLanguage l) => _isUrdu(l) ? 'تبدیل کریں' : 'Switch';
  static String countAction(AppLanguage l) => _isUrdu(l) ? 'گنیں' : 'COUNT';

  static String countLabel(AppLanguage l) => _isUrdu(l) ? 'گنتی' : 'Count';
  static String targetLabel(AppLanguage l) => _isUrdu(l) ? 'ہدف' : 'Target';
  static String customZikr(AppLanguage l) => _isUrdu(l) ? 'حسب ضرورت ذکر' : 'Custom Zikr';
  static String addCustomZikr(AppLanguage l) => _isUrdu(l) ? 'نیا حسب ضرورت ذکر شامل کریں' : 'Add Custom Zikr';
  static String nameHint(AppLanguage l) => _isUrdu(l) ? 'نام (انگریزی یا اردو)' : 'Name (English or Urdu)';
  static String targetHint(AppLanguage l) => _isUrdu(l) ? 'ہدف کی تعداد' : 'Target Count';
  static String add(AppLanguage l) => _isUrdu(l) ? 'شامل کریں' : 'Add';
  static String selectSound(AppLanguage l) => _isUrdu(l) ? 'آواز منتخب کریں' : 'Select Sound';
  static String soundClick(AppLanguage l) => _isUrdu(l) ? 'کلک' : 'Click';
  static String soundPop(AppLanguage l) => _isUrdu(l) ? 'پاپ' : 'Pop';
  static String soundSoft(AppLanguage l) => _isUrdu(l) ? 'نرم' : 'Soft';
  static String active(AppLanguage l) => _isUrdu(l) ? 'فعال' : 'Active';
  static String sound(AppLanguage l) => _isUrdu(l) ? 'آواز' : 'Sound';
  static String vibration(AppLanguage l) => _isUrdu(l) ? 'وائبریشن' : 'Vibration';
  static String language(AppLanguage l) => _isUrdu(l) ? 'زبان' : 'Language';
  static String pressBackToExit(AppLanguage l) => _isUrdu(l) ? 'بند کرنے کے لیے دوبارہ بیک دبائیں' : 'Press back again to exit';
  static String resetQuestion(AppLanguage l) => _isUrdu(l) ? 'کیا آپ واقعی ری سیٹ کرنا چاہتے ہیں؟' : 'Are you sure you want to reset?';
  static String cancel(AppLanguage l) => _isUrdu(l) ? 'منسوخ کریں' : 'Cancel';
  static String ok(AppLanguage l) => _isUrdu(l) ? 'ٹھیک ہے' : 'OK';
  static String autoSpeedTitle(AppLanguage l) => _isUrdu(l) ? 'خودکار رفتار' : 'Auto Speed';
  static String autoSpeedHint(AppLanguage l) => _isUrdu(l) ? 'اپنی مطلوبہ رفتار سے یہاں 3 بار ٹیپ کریں' : 'Tap here 3 times at your desired speed';
  static String tapsProgress(AppLanguage l, int count) => _isUrdu(l) ? 'ٹیپس: $count/3' : 'Taps: $count/3';
}
