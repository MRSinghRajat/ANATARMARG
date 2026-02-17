import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/widgets/reader_settings_modal.dart' show ReaderTheme, ReaderFont, ReaderLayout;

class ReaderPreferencesService {
  static const String keyFontSize = 'reader_font_size';
  static const String keyTheme = 'reader_theme';
  static const String keyFont = 'reader_font';
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
    final fontIndex = prefs.getInt(keyFont);
    if (fontIndex == null) return ReaderFont.serif;
    return ReaderFont.values[fontIndex.clamp(0, ReaderFont.values.length - 1)];
  }

  Future<void> saveFont(ReaderFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyFont, font.index);
  }

  Future<ReaderLayout> loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutIndex = prefs.getInt(keyLayout);
    if (layoutIndex == null) return ReaderLayout.scroll;
    return ReaderLayout.values[layoutIndex.clamp(0, ReaderLayout.values.length - 1)];
  }

  Future<void> saveLayout(ReaderLayout layout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLayout, layout.index);
  }
}
