import 'package:antarmarg/core/config/app_config.dart';
import 'package:antarmarg/core/utils/app_router.dart';
import 'package:antarmarg/features/profile/presentation/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final lang in ['en', 'hi']) {
    testWidgets('About $lang scales and opens legal destinations',
        (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        routes: {
          AppRouter.termsOfService: (_) =>
              const Scaffold(body: Text('Terms destination')),
          AppRouter.privacyPolicy: (_) =>
              const Scaffold(body: Text('Privacy destination')),
        },
        home: const AboutScreen(),
      )));
      await tester.pumpAndSettle();
      expect(find.text(AppConfig.appDisplayName), findsOneWidget);
      expect(find.textContaining(AppConfig.appVersion), findsOneWidget);
      final terms =
          find.text(lang == 'hi' ? 'सेवा की शर्तें' : 'Terms of Service');
      await tester.scrollUntilVisible(terms, 200);
      await tester.pumpAndSettle();
      await tester.tap(terms);
      await tester.pumpAndSettle();
      expect(find.text('Terms destination'), findsOneWidget);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();
      final privacy =
          find.text(lang == 'hi' ? 'गोपनीयता नीति' : 'Privacy Policy');
      await tester.scrollUntilVisible(privacy, 200);
      await tester.pumpAndSettle();
      await tester.tap(privacy);
      await tester.pumpAndSettle();
      expect(find.text('Privacy destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
