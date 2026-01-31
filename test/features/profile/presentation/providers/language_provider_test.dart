import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antar_marg/features/profile/presentation/providers/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageNotifier', () {
    test('initial state is "en"', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final language = container.read(languageProvider);
      expect(language, 'en');
    });

    test('loads saved language from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'language_code': 'hi'});
      final container = ProviderContainer();

      // We need to wait for the notifier to load the language.
      // Since the load is triggered in the constructor, we can't await it directly.
      // We'll poll for the state change.
      String language = container.read(languageProvider);

      if (language != 'hi') {
        for (int i = 0; i < 20; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
          language = container.read(languageProvider);
          if (language == 'hi') break;
        }
      }

      expect(language, 'hi');
    });

    test('setLanguage updates state and SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(languageProvider.notifier);

      await notifier.setLanguage('sa');

      final language = container.read(languageProvider);
      expect(language, 'sa');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_code'), 'sa');
    });
  });
}
