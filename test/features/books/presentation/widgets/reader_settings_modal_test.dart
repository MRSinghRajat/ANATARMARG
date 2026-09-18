import 'package:antarmarg/features/books/data/services/reader_preferences_service.dart';
import 'package:antarmarg/features/books/presentation/widgets/reader_settings_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('reader settings fit large text and persist selections',
      (tester) async {
    SharedPreferences.setMockInitialValues({'reader_font_size': 100.0});
    final preferences = ReaderPreferencesService();
    expect(await preferences.loadFontSize(), 32);
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(
            body: ReaderSettingsModal(
          currentFontSize: 100,
          currentTheme: ReaderTheme.dark,
          currentFont: ReaderFont.serif,
          onFontSizeChanged: preferences.saveFontSize,
          onThemeChanged: preferences.saveTheme,
          onFontChanged: preferences.saveFont,
          onLayoutChanged: preferences.saveLayout,
        )),
      ),
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scroll'));
    await tester.pumpAndSettle();
    expect(await preferences.loadLayout(), ReaderLayout.scroll);
    await tester.scrollUntilVisible(find.text('Devanagari'), 200);
    await tester.tap(find.text('Devanagari'));
    await tester.pumpAndSettle();
    expect(await preferences.loadFont(), ReaderFont.devanagari);
    expect(tester.takeException(), isNull);
  });
}
