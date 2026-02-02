import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/widgets/reader_settings_modal.dart' show ReaderTheme, ReaderFont;

class ReaderPreferencesService {
  static const String keyFontSize = 'reader_font_size';
  static const String keyTheme = 'reader_theme';
  static const String keyFont = 'reader_font';

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
    if (themeIndex == null) return ReaderTheme.paper; // Default to Paper (Sepia)
    return ReaderTheme.values[themeIndex.clamp(0, ReaderTheme.values.length - 1)];
  }

  Future<void> saveTheme(ReaderTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTheme, theme.index);
  }

  Future<ReaderFont> loadFont() async {
    final prefs = await SharedPreferences.getInstance();
    final fontIndex = prefs.getInt(keyFont);
    if (fontIndex == null) return ReaderFont.serif; // Default to Serif
    return ReaderFont.values[fontIndex.clamp(0, ReaderFont.values.length - 1)];
  }

  Future<void> saveFont(ReaderFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyFont, font.index);
  }
}
