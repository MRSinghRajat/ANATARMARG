import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antarmarg/core/l10n/localized.dart';
import 'package:antarmarg/features/profile/presentation/providers/language_provider.dart';

void main() {
  group('localizedLang', () {
    test('returns English when lang is en even if Hindi exists', () {
      expect(
        localizedLang('en', en: 'Garbh Sanskar', hi: 'गर्भ संस्कार'),
        'Garbh Sanskar',
      );
    });

    test('returns Hindi when lang is hi and Hindi is non-empty', () {
      expect(
        localizedLang('hi', en: 'Garbh Sanskar', hi: 'गर्भ संस्कार'),
        'गर्भ संस्कार',
      );
    });

    test('falls back to English when Hindi is null', () {
      expect(localizedLang('hi', en: 'Little Sadhu', hi: null), 'Little Sadhu');
    });

    test('falls back to English when Hindi is empty', () {
      expect(localizedLang('hi', en: 'Little Sadhu', hi: ''), 'Little Sadhu');
    });
  });

  testWidgets('localized reads languageProvider', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp(
              home: Text(localized(ref, en: 'Journey', hi: 'यात्रा')),
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Journey'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Text)),
    );
    await container.read(languageProvider.notifier).setLanguage('hi');
    await tester.pump();
    expect(find.text('यात्रा'), findsOneWidget);
  });
}
