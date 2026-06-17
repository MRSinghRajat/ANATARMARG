import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/widgets/reader_settings_modal.dart' show ReaderTheme, ReaderFont, ReaderLayout;

class ReaderPreferencesService {
  static const String keyFontSize = 'reader_font_size';
  static const String keyTheme = 'reader_theme';
  /// Legacy index storage (10 font variants); superseded by [keyFontV2].
  static const String keyFontLegacy = 'reader_font';
  static const String keyFontV2 = 'reader_font_v2';
  static const String keyLayout = 'reader_layout';

  Future<double> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyFontSize) ?? 18.0;
  }

  Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyFontSize, size);
  }

  Future<ReaderTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(keyTheme);
    if (themeIndex == null) return ReaderTheme.paper;
    return ReaderTheme.values[themeIndex.clamp(0, ReaderTheme.values.length - 1)];
  }

  Future<void> saveTheme(ReaderTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTheme, theme.index);
  }

  Future<ReaderFont> loadFont() async {
    final prefs = await SharedPreferences.getInstance();
    final v2 = prefs.getInt(keyFontV2);
    if (v2 != null) {
      return ReaderFont.values[v2.clamp(0, ReaderFont.values.length - 1)];
    }
    final legacy = prefs.getInt(keyFontLegacy);
    final migrated = _migrateLegacyReaderFont(legacy);
    await prefs.setInt(keyFontV2, migrated.index);
    return migrated;
  }

  /// Maps pre–3-option [ReaderFont] indices without conflating legacy index 2
  /// (Rounded) with new index 2 (Devanagari).
  ReaderFont _migrateLegacyReaderFont(int? legacyIndex) {
    if (legacyIndex == null) return ReaderFont.serif;
    switch (legacyIndex) {
      case 0:
        return ReaderFont.serif;
      case 1:
        return ReaderFont.sans;
      case 5:
        return ReaderFont.devanagari;
      default:
        return ReaderFont.serif;
    }
  }

  Future<void> saveFont(ReaderFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyFontV2, font.index);
  }

  Future<ReaderLayout> loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutIndex = prefs.getInt(keyLayout);
    if (layoutIndex == null) return ReaderLayout.card;
    return ReaderLayout.values[layoutIndex.clamp(0, ReaderLayout.values.length - 1)];
  }

  Future<void> saveLayout(ReaderLayout layout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLayout, layout.index);
  }
}
